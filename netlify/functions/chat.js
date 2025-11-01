const { Anthropic } = require('@anthropic-ai/sdk');  // Destructure for clarity

exports.handler = async (event) => {
    if (event.httpMethod !== 'POST') {
        return {
            statusCode: 405,
            body: JSON.stringify({ error: 'Method Not Allowed' })
        };
    }

    try {
        // --- NEW: Destructure city and postcode ---
        const { messages, country, userName, city, postcode } = JSON.parse(event.body);
        // -----------------------------------------

        if (!messages || !Array.isArray(messages)) {
            return {
                statusCode: 400,
                body: JSON.stringify({ error: 'Invalid request: messages array required' })
            };
        }

        const anthropic = new Anthropic({
            apiKey: process.env.ANTHROPIC_API_KEY
        });

        // --- NEW: Pass city and postcode to system prompt function ---
        const systemPrompt = getSystemPrompt(country, userName, city, postcode);
        // -------------------------------------------------------------

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

// --- NEW/UPDATED: Function signature and prompt content for location awareness ---
function getSystemPrompt(country = 'unspecified', userName = 'user', city = 'unspecified city/region', postcode = 'unspecified postcode/zip') {
    return `You are DisabilityConnect, a helpful and empathetic AI assistant that helps ${userName} find disability support services in ${country}.

**USER LOCATION CONTEXT:**
- User's Service Country: ${country}
- User's City/Region/State: ${city}
- User's Postcode/Zip: ${postcode}

Your primary goal is to provide service recommendations that are as *local and specific as possible* using the City/Region/State and Postcode/Zip.

**SPECIFIC GEOGRAPHIC GUIDANCE:**
1. **Australia (AU):** Prioritize NDIS information. Use the State/Territory (often found in the 'City/Region' field, e.g., 'Sydney, NSW') and the postcode to mention regional vs metropolitan differences in service delivery.
2. **United States (US):** Use the State (from the 'City/Region' field) to mention relevant Medicaid waivers, state-funded programs, or regional non-profits specific to that state.
3. **United Kingdom (UK):** Use the City and Postcode to reference local council services, health trusts, or regional charities (e.g., specific to London boroughs, Scottish councils, etc.).
4. **Canada (CA):** Use the Province/Territory (from the 'City/Region' field) to reference provincial government funding programs and regional services.
5. **Other Countries:** Acknowledge the location and state that you will use general best-practice information, noting that the team will follow up personally with more specific research.

CONVERSATION APPROACH:
1. First, confirm the country and the location you will be focusing on, for example: "I will focus on resources for ${city}, ${country}."
2. Ask about their specific challenges (mobility, self-care, communication, cognitive, etc.) to tailor the advice.
3. Be empathetic, concise, and professional. Only provide information that is verifiable or commonly accepted as guidance.`;
}
// ---------------------------------------------------------------------------------
