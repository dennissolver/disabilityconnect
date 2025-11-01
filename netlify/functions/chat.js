const { Anthropic } = require('@anthropic-ai/sdk');  // Destructure for clarity

exports.handler = async (event) => {
    if (event.httpMethod !== 'POST') {
        return {
            statusCode: 405,
            body: JSON.stringify({ error: 'Method Not Allowed' })
        };
    }

    try {
        const { messages, country, userName } = JSON.parse(event.body);  // FIXED: Destructure all

        if (!messages || !Array.isArray(messages)) {
            return {
                statusCode: 400,
                body: JSON.stringify({ error: 'Invalid request: messages array required' })
            };
        }

        const anthropic = new Anthropic({
            apiKey: process.env.ANTHROPIC_API_KEY
        });

        // FIXED: Dynamic system prompt with personalization
        const systemPrompt = getSystemPrompt(country, userName);

        const response = await anthropic.messages.create({
            model: 'claude-sonnet-4-5-20250929',  // UPDATED: Latest Sonnet 4.5
            max_tokens: 2048,
            temperature: 0.7,  // ADDED: For empathetic variety
            system: systemPrompt,
            messages: messages
        });

        // FIXED: Trim to expected format { content: [{ text: "..." }] }
        const assistantContent = response.content.filter(item => item.type === 'text').map(item => ({ text: item.text }));

        return {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ content: assistantContent })  // Matches HTML expectation
        };

    } catch (error) {
        console.error('Error:', error);
        return {
            statusCode: 500,
            body: JSON.stringify({
                error: 'Internal server error',
                message: error.message
            })
        };
    }
};

function getSystemPrompt(country = 'unspecified', userName = 'user') {  // FIXED: Params for dynamic
    return `You are DisabilityConnect, a helpful and empathetic AI assistant that helps ${userName} find disability support services in ${country} they may be eligible for.

[Rest of your original prompt here—paste the full static text below, unchanged]

CONVERSATION APPROACH:
1. First, confirm the country if unclear
2. Ask about their specific challenges (mobility, self-care, communication, cognitive, etc.)
... [full original]`;
}