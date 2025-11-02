const { Anthropic } = require('@anthropic-ai/sdk');  // Destructure for clarity

// --- NEW: Google Apps Script URL (same as frontend) ---
const GOOGLE_SHEET_URL = 'https://script.google.com/macros/s/AKfycbw6UyWZ9vIomPXXsIbICrKi1bUrrEFNyCbe3oG_BKRcVFQ1a55QRR0hX_DrZ1Wipn-k/exec';
// --------------------------------------------------------

exports.handler = async (event) => {
    if (event.httpMethod !== 'POST') {
        return {
            statusCode: 405,
            body: JSON.stringify({ error: 'Method Not Allowed' })
        };
    }

    try {
        const { action, messages, country, userName, city, postcode, email, transcript } = JSON.parse(event.body);

        // --- NEW: Transcript Saving Dispatch ---
        if (action === 'save_transcript' && email && transcript) {
             console.log(`Dispatching transcript save for ${email}`);
             // Forward the request to the Google Apps Script
             await fetch(GOOGLE_SHEET_URL, {
                method: 'POST',
                // Note: Netlify Functions use a regular fetch, so mode: 'no-cors' is not needed here
                headers: { 'Content-Type': 'text/plain' },
                body: JSON.stringify({ action: 'save_transcript', email, transcript })
            });
            return {
                statusCode: 200,
                body: JSON.stringify({ success: true, message: 'Transcript save initiated.' })
            };
        }
        // ---------------------------------------

        // --- Standard Chat Logic (if action is 'chat' or undefined) ---
        if (!messages || !Array.isArray(messages)) {
            return {
                statusCode: 400,
                body: JSON.stringify({ error: 'Invalid request: messages array required for chat action.' })
            };
        }

        const anthropic = new Anthropic({
            apiKey: process.env.ANTHROPIC_API_KEY
        });

        const systemPrompt = getSystemPrompt(country, userName, city, postcode);

        const response = await anthropic.messages.create({
            model: 'claude-sonnet-4-5-20250929',
            max_tokens: 2048,
            temperature: 0.7,
            system: systemPrompt,
            messages: messages
        });

        const assistantContent = response.content.filter(item => item.type === 'text').map(item => ({ text: item.text }));

        return {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ content: assistantContent })
        };

    } catch (error) {
        console.error('Error in chat handler:', error);
        return {
            statusCode: 500,
            body: JSON.stringify({
                error: 'Internal server error',
                message: error.message
            })
        };
    }
};

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
