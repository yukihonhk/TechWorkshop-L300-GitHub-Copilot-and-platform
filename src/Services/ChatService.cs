using Azure;
using Azure.AI.Inference;

namespace ZavaStorefront.Services
{
    public class ChatService
    {
        private readonly ChatCompletionsClient _client;
        private readonly string _deploymentName;
        private readonly ILogger<ChatService> _logger;

        public ChatService(IConfiguration configuration, ILogger<ChatService> logger)
        {
            _logger = logger;

            var endpoint = configuration["AzureAI:Endpoint"] 
                ?? throw new InvalidOperationException("AzureAI:Endpoint is not configured.");
            var apiKey = configuration["AzureAI:ApiKey"] 
                ?? throw new InvalidOperationException("AzureAI:ApiKey is not configured.");
            _deploymentName = configuration["AzureAI:DeploymentName"] ?? "Phi-4";

            _client = new ChatCompletionsClient(
                new Uri(endpoint),
                new AzureKeyCredential(apiKey));
        }

        public async Task<string> GetChatResponseAsync(List<ChatMessage> conversationHistory)
        {
            try
            {
                var requestOptions = new ChatCompletionsOptions
                {
                    Model = _deploymentName
                };

                foreach (var message in conversationHistory)
                {
                    switch (message.Role)
                    {
                        case "system":
                            requestOptions.Messages.Add(new ChatRequestSystemMessage(message.Content));
                            break;
                        case "user":
                            requestOptions.Messages.Add(new ChatRequestUserMessage(message.Content));
                            break;
                        case "assistant":
                            requestOptions.Messages.Add(new ChatRequestAssistantMessage(message.Content));
                            break;
                    }
                }

                var response = await _client.CompleteAsync(requestOptions);
                var result = response.Value.Content;

                _logger.LogInformation("Received response from Phi-4 model ({TokenCount} tokens used)", 
                    response.Value.Usage?.TotalTokens ?? 0);

                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error calling Phi-4 model");
                return $"Error: Unable to get a response from the AI model. {ex.Message}";
            }
        }
    }

    public class ChatMessage
    {
        public string Role { get; set; } = string.Empty;
        public string Content { get; set; } = string.Empty;
    }
}
