using Azure;
using Azure.AI.Inference;

namespace ZavaStorefront.Services
{
    public class ChatService
    {
        private readonly ChatCompletionsClient? _client;
        private readonly string _deploymentName;
        private readonly ILogger<ChatService> _logger;
        private readonly bool _isConfigured;

        public ChatService(IConfiguration configuration, ILogger<ChatService> logger)
        {
            _logger = logger;
            _deploymentName = configuration["AzureAI:DeploymentName"] ?? "Phi-4";

            var endpoint = configuration["AzureAI:Endpoint"];
            var apiKey = configuration["AzureAI:ApiKey"];

            if (string.IsNullOrEmpty(endpoint) || string.IsNullOrEmpty(apiKey))
            {
                _logger.LogWarning("AzureAI:Endpoint or AzureAI:ApiKey is not configured. Chat feature will be unavailable.");
                _isConfigured = false;
                return;
            }

            _client = new ChatCompletionsClient(
                new Uri(endpoint),
                new AzureKeyCredential(apiKey));
            _isConfigured = true;
        }

        public bool IsConfigured => _isConfigured;

        public async Task<string> GetChatResponseAsync(List<ChatMessage> conversationHistory)
        {
            try
            {
                if (!_isConfigured || _client == null)
                {
                    return "Chat is not available. The AI service is not configured. Please set AzureAI:Endpoint and AzureAI:ApiKey in the application settings.";
                }
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
