#!/usr/bin/env node
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';
import axios from 'axios';
import dotenv from 'dotenv';

dotenv.config();

class DigitalOceanServer {
  constructor() {
    this.apiToken = process.env.DIGITALOCEAN_API_TOKEN;
    this.apiUrl = 'https://api.digitalocean.com/v2';
    this.axiosInstance = axios.create({
      baseURL: this.apiUrl,
      headers: {
        'Authorization': `Bearer ${this.apiToken}`,
        'Content-Type': 'application/json'
      }
    });
  }

  async listDroplets() {
    try {
      const response = await this.axiosInstance.get('/droplets');
      return response.data.droplets;
    } catch (error) {
      throw new Error(`Failed to list droplets: ${error.message}`);
    }
  }

  async executeCommand(dropletId, command) {
    // Note: DigitalOcean doesn't have a direct API for SSH commands
    // This is a placeholder for the actual implementation
    return {
      message: "Direct command execution requires SSH access. Use the console or set up SSH keys.",
      dropletId,
      command
    };
  }

  async getDropletConsoleUrl(dropletId) {
    // Generate console URL for manual access
    return `https://cloud.digitalocean.com/droplets/${dropletId}/console`;
  }

  async restartDroplet(dropletId) {
    try {
      await this.axiosInstance.post(`/droplets/${dropletId}/actions`, {
        type: 'reboot'
      });
      return { success: true, message: `Droplet ${dropletId} is rebooting` };
    } catch (error) {
      throw new Error(`Failed to restart droplet: ${error.message}`);
    }
  }
}

const server = new Server(
  {
    name: 'digitalocean-mcp',
    version: '1.0.0',
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

const doServer = new DigitalOceanServer();

server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: 'list_droplets',
        description: 'List all DigitalOcean droplets',
        inputSchema: {
          type: 'object',
          properties: {},
        },
      },
      {
        name: 'get_console_url',
        description: 'Get the console URL for a droplet',
        inputSchema: {
          type: 'object',
          properties: {
            dropletId: {
              type: 'string',
              description: 'The ID of the droplet',
            },
          },
          required: ['dropletId'],
        },
      },
      {
        name: 'restart_droplet',
        description: 'Restart a DigitalOcean droplet',
        inputSchema: {
          type: 'object',
          properties: {
            dropletId: {
              type: 'string',
              description: 'The ID of the droplet to restart',
            },
          },
          required: ['dropletId'],
        },
      },
      {
        name: 'execute_command',
        description: 'Placeholder for command execution (requires SSH setup)',
        inputSchema: {
          type: 'object',
          properties: {
            dropletId: {
              type: 'string',
              description: 'The ID of the droplet',
            },
            command: {
              type: 'string',
              description: 'The command to execute',
            },
          },
          required: ['dropletId', 'command'],
        },
      },
    ],
  };
});

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    switch (name) {
      case 'list_droplets': {
        const droplets = await doServer.listDroplets();
        return {
          content: [
            {
              type: 'text',
              text: JSON.stringify(droplets, null, 2),
            },
          ],
        };
      }

      case 'get_console_url': {
        const url = await doServer.getDropletConsoleUrl(args.dropletId);
        return {
          content: [
            {
              type: 'text',
              text: `Console URL: ${url}`,
            },
          ],
        };
      }

      case 'restart_droplet': {
        const result = await doServer.restartDroplet(args.dropletId);
        return {
          content: [
            {
              type: 'text',
              text: result.message,
            },
          ],
        };
      }

      case 'execute_command': {
        const result = await doServer.executeCommand(args.dropletId, args.command);
        return {
          content: [
            {
              type: 'text',
              text: JSON.stringify(result, null, 2),
            },
          ],
        };
      }

      default:
        throw new Error(`Unknown tool: ${name}`);
    }
  } catch (error) {
    return {
      content: [
        {
          type: 'text',
          text: `Error: ${error.message}`,
        },
      ],
    };
  }
});

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error('DigitalOcean MCP server running...');
}

main().catch((error) => {
  console.error('Server error:', error);
  process.exit(1);
});
