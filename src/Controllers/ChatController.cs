using Microsoft.AspNetCore.Mvc;
using ZavaStorefront.Services;
using System.Text.Json;

namespace ZavaStorefront.Controllers;

public class ChatController : Controller
{
    private const string ChatHistorySessionKey = "ChatHistory";
    private readonly ChatService _chatService;
    private readonly ILogger<ChatController> _logger;

    public ChatController(ChatService chatService, ILogger<ChatController> logger)
    {
        _chatService = chatService;
        _logger = logger;
    }

    public IActionResult Index()
    {
        var history = GetChatHistory();
        return View(history);
    }

    [HttpPost]
    public async Task<IActionResult> SendMessage(string userMessage)
    {
        if (string.IsNullOrWhiteSpace(userMessage))
        {
            return RedirectToAction("Index");
        }

        _logger.LogInformation("User sent chat message: {MessagePreview}", 
            userMessage.Length > 50 ? userMessage[..50] + "..." : userMessage);

        var history = GetChatHistory();

        // Add system message if this is the start of conversation
        if (history.Count == 0)
        {
            history.Add(new ChatMessage
            {
                Role = "system",
                Content = "You are a helpful shopping assistant for Zava Storefront. Help customers with product questions, recommendations, and general inquiries. Be friendly and concise."
            });
        }

        // Add user message
        history.Add(new ChatMessage
        {
            Role = "user",
            Content = userMessage
        });

        // Get AI response
        var response = await _chatService.GetChatResponseAsync(history);

        // Add assistant response
        history.Add(new ChatMessage
        {
            Role = "assistant",
            Content = response
        });

        SaveChatHistory(history);

        return RedirectToAction("Index");
    }

    [HttpPost]
    public IActionResult ClearChat()
    {
        HttpContext.Session.Remove(ChatHistorySessionKey);
        _logger.LogInformation("Chat history cleared");
        return RedirectToAction("Index");
    }

    private List<ChatMessage> GetChatHistory()
    {
        var json = HttpContext.Session.GetString(ChatHistorySessionKey);
        if (string.IsNullOrEmpty(json))
        {
            return new List<ChatMessage>();
        }
        return JsonSerializer.Deserialize<List<ChatMessage>>(json) ?? new List<ChatMessage>();
    }

    private void SaveChatHistory(List<ChatMessage> history)
    {
        var json = JsonSerializer.Serialize(history);
        HttpContext.Session.SetString(ChatHistorySessionKey, json);
    }
}
