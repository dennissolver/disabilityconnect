# DisabilityConnect Project Setup Script
Write-Host "Creating DisabilityConnect project structure..." -ForegroundColor Green

# Create directory structure
Write-Host "Creating folders..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "netlify/functions" | Out-Null

# Create index.html
Write-Host "Creating index.html..." -ForegroundColor Yellow
$indexHtml = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DisabilityConnect - Find Your Support Services</title>
    <meta name="description" content="Get personalized guidance on disability services and support programs in your country">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Arial, sans-serif;
            background-color: #f5f5f5;
            line-height: 1.6;
        }

        .container {
            max-width: 900px;
            margin: 0 auto;
            padding: 20px;
            height: 100vh;
            display: flex;
            flex-direction: column;
        }

        header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            border-radius: 12px 12px 0 0;
            text-align: center;
        }

        header h1 {
            font-size: 28px;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }

        header p {
            font-size: 15px;
            opacity: 0.95;
        }

        .chat-container {
            flex: 1;
            background: white;
            padding: 20px;
            overflow-y: auto;
            border-left: 1px solid #ddd;
            border-right: 1px solid #ddd;
        }

        .message {
            margin: 15px 0;
            display: flex;
            align-items: flex-start;
            gap: 12px;
            animation: fadeIn 0.3s ease-in;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .message.user {
            flex-direction: row-reverse;
        }

        .message-content {
            max-width: 75%;
            padding: 14px 18px;
            border-radius: 16px;
            word-wrap: break-word;
            white-space: pre-wrap;
        }

        .message.assistant .message-content {
            background-color: #f0f0f0;
            border-bottom-left-radius: 4px;
        }

        .message.user .message-content {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-bottom-right-radius: 4px;
        }

        .message-icon {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            flex-shrink: 0;
            font-size: 18px;
        }

        .message.assistant .message-icon {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }

        .message.user .message-icon {
            background-color: #e0e0e0;
            color: #666;
        }

        .loading {
            display: inline-block;
        }

        .loading::after {
            content: '...';
            animation: dots 1.5s steps(4, end) infinite;
        }

        @keyframes dots {
            0%, 20% { content: '.'; }
            40% { content: '..'; }
            60%, 100% { content: '...'; }
        }

        .input-area {
            background: white;
            padding: 20px;
            border: 1px solid #ddd;
            border-radius: 0 0 12px 12px;
            display: flex;
            gap: 12px;
        }

        textarea {
            flex: 1;
            padding: 14px;
            border: 2px solid #ddd;
            border-radius: 12px;
            resize: none;
            font-family: inherit;
            font-size: 15px;
            transition: border-color 0.3s;
        }

        textarea:focus {
            outline: none;
            border-color: #667eea;
        }

        button {
            padding: 14px 28px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 12px;
            cursor: pointer;
            font-weight: 600;
            transition: transform 0.2s, box-shadow 0.2s;
            min-width: 90px;
            font-size: 15px;
        }

        button:hover:not(:disabled) {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
        }

        button:active:not(:disabled) {
            transform: translateY(0);
        }

        button:disabled {
            background: #ccc;
            cursor: not-allowed;
            transform: none;
        }

        .error-message {
            background-color: #ffebee;
            color: #c62828;
            padding: 14px;
            border-radius: 8px;
            margin: 10px 0;
        }

        ul, ol {
            margin-left: 20px;
            margin-top: 8px;
        }

        li {
            margin: 6px 0;
        }

        strong {
            color: #333;
        }

        a {
            color: #667eea;
            text-decoration: none;
        }

        a:hover {
            text-decoration: underline;
        }

        .disclaimer {
            background-color: #fff3cd;
            border-left: 4px solid #ffc107;
            padding: 12px;
            margin: 15px 0;
            font-size: 13px;
            border-radius: 4px;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>
                <span>🤝</span>
                DisabilityConnect
            </h1>
            <p>Find the support services you're entitled to</p>
        </header>

        <div class="chat-container" id="chatContainer">
            <div class="message assistant">
                <div class="message-icon">DC</div>
                <div class="message-content">
                    <strong>Welcome to DisabilityConnect!</strong>
                    <br><br>
                    I'm here to help you find disability support services that match your needs.
                    <br><br>
                    To get started, please tell me:
                    <ul>
                        <li>Which country you're in</li>
                        <li>What challenges you're facing</li>
                        <li>What kind of support you need</li>
                    </ul>
                    <div class="disclaimer">
                        <strong>Note:</strong> I provide guidance only. Always verify eligibility with official sources.
                    </div>
                </div>
            </div>
        </div>

        <div class="input-area">
            <textarea
                id="userInput"
                placeholder="Describe your situation... (Press Enter to send, Shift+Enter for new line)"
                rows="3"
                aria-label="Message input"
            ></textarea>
            <button id="sendBtn" onclick="sendMessage()">Send</button>
        </div>
    </div>

    <script>
        let conversationHistory = [];
        let messageCount = 0;

        async function sendMessage() {
            const input = document.getElementById('userInput');
            const message = input.value.trim();

            if (!message) return;

            const sendBtn = document.getElementById('sendBtn');
            sendBtn.disabled = true;
            input.disabled = true;

            addMessage(message, 'user');
            input.value = '';

            const loadingId = addMessage('Thinking', 'assistant', true);

            try {
                conversationHistory.push({
                    role: 'user',
                    content: message
                });

                const response = await fetch('/.netlify/functions/chat', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        messages: conversationHistory
                    })
                });

                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }

                const data = await response.json();

                document.getElementById(loadingId).remove();

                if (data.content && data.content[0]) {
                    const assistantMessage = data.content[0].text;
                    conversationHistory.push({
                        role: 'assistant',
                        content: assistantMessage
                    });
                    addMessage(assistantMessage, 'assistant');
                } else {
                    throw new Error('Invalid response format');
                }

            } catch (error) {
                console.error('Error:', error);
                document.getElementById(loadingId)?.remove();
                addMessage(
                    'Sorry, I encountered an error. Please try again.',
                    'assistant'
                );
            } finally {
                sendBtn.disabled = false;
                input.disabled = false;
                input.focus();
            }
        }

        function addMessage(text, sender, isLoading = false) {
            const container = document.getElementById('chatContainer');
            const messageDiv = document.createElement('div');
            const id = 'msg-' + (++messageCount);

            messageDiv.id = id;
            messageDiv.className = `message ${sender}`;

            const icon = document.createElement('div');
            icon.className = 'message-icon';
            icon.textContent = sender === 'assistant' ? 'DC' : 'You';

            const content = document.createElement('div');
            content.className = 'message-content';

            if (isLoading) {
                content.innerHTML = '<span class="loading">Thinking</span>';
            } else {
                content.textContent = text;
            }

            messageDiv.appendChild(icon);
            messageDiv.appendChild(content);
            container.appendChild(messageDiv);
            container.scrollTop = container.scrollHeight;

            return id;
        }

        document.getElementById('userInput').addEventListener('keydown', function(e) {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                sendMessage();
            }
        });

        window.addEventListener('load', () => {
            document.getElementById('userInput').focus();
        });
    </script>
</body>
</html>
'@
Set-Content -Path "index.html" -Value $indexHtml

# Create chat.js
Write-Host "Creating netlify/functions/chat.js..." -ForegroundColor Yellow
$chatJs = @'
const Anthropic = require('@anthropic-ai/sdk');

exports.handler = async (event) => {
    if (event.httpMethod !== 'POST') {
        return {
            statusCode: 405,
            body: JSON.stringify({ error: 'Method Not Allowed' })
        };
    }

    try {
        const { messages } = JSON.parse(event.body);

        if (!messages || !Array.isArray(messages)) {
            return {
                statusCode: 400,
                body: JSON.stringify({ error: 'Invalid request: messages array required' })
            };
        }

        const anthropic = new Anthropic({
            apiKey: process.env.ANTHROPIC_API_KEY
        });

        const response = await anthropic.messages.create({
            model: 'claude-sonnet-4-20250514',
            max_tokens: 2048,
            system: getSystemPrompt(),
            messages: messages
        });

        return {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(response)
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

function getSystemPrompt() {
    return `You are DisabilityConnect, a helpful and empathetic AI assistant that helps people find disability support services they may be eligible for.

Your role is to:
1. Have a warm, conversational tone while being professional
2. Ask clarifying questions to understand the user's situation
3. Match their needs to relevant services
4. Explain WHY each service matches their situation
5. Provide clear, actionable next steps with official links
6. Use plain language and avoid jargon

IMPORTANT GUIDELINES:
- Always ask for the user's country early in the conversation if not mentioned
- Focus on functional impacts rather than diagnoses
- Be empathetic and supportive - many users may be stressed or overwhelmed
- Provide 2-4 most relevant services, not an overwhelming list
- Include confidence levels: "Strong match", "Worth exploring", "Possible option"
- Always include official website links
- Remind users to verify eligibility with official sources
- Never diagnose medical conditions
- Use bullet points for clarity when listing multiple services

AVAILABLE SERVICES DATABASE:

=== UNITED KINGDOM ===

**Personal Independence Payment (PIP)**
- Eligibility: Age 16-64, long-term health condition or disability affecting daily activities or mobility for 3+ months, expected to last 9+ months
- Provides: £28-£184 per week (2024 rates)
- Covers: Daily living difficulties, mobility issues
- Application: gov.uk/pip or call 0800 121 4433
- Timeline: 3-6 months average
- Assessment: Face-to-face, video, or phone assessment required

**Disability Living Allowance (DLA) for Children**
- Eligibility: Under 16 with disabilities needing more care than children same age
- Provides: £28-£184 per week
- Application: gov.uk/disability-living-allowance-children
- Note: Adults use PIP instead

**Access to Work**
- Eligibility: Working or about to start work, have a disability or health condition
- Provides: Grants for workplace adaptations, equipment, support workers
- Covers: Up to £66,000 per year
- Application: gov.uk/access-to-work

**Blue Badge (Disabled Parking)**
- Eligibility: Cannot walk or have significant difficulty walking
- Provides: Parking concessions
- Application: Through local council
- Cost: Up to £10 for 3 years

**Direct Payments**
- Eligibility: Assessed by local council as needing care and support
- Provides: Money to arrange your own care instead of council-arranged services
- Application: Contact your local council social services
- Flexibility: Hire own carers, purchase equipment

**Attendance Allowance**
- Eligibility: Age 65+, need help with personal care or supervision
- Provides: £72-£108 per week
- Application: gov.uk/attendance-allowance

=== AUSTRALIA ===

**NDIS (National Disability Insurance Scheme)**
- Eligibility: Under 65, Australian resident, permanent and significant disability that affects daily activities
- Provides: Individualized funding packages for supports and services
- Covers: Therapy, equipment, home modifications, daily living support, employment assistance
- Application: ndis.gov.au or call 1800 800 110
- Timeline: 21 days for access decision, then planning meeting
- Key: Must show disability is permanent and significantly impacts daily life

**Disability Support Pension**
- Eligibility: 16+, permanent condition preventing work (15+ hours/week), Australian resident
- Provides: Fortnightly payments (income tested)
- Application: servicesaustralia.gov.au
- Assessment: Medical evidence required

**Carer Payment & Carer Allowance**
- Eligibility: Caring for someone with disability or medical condition
- Carer Payment: Income support (income tested)
- Carer Allowance: Supplement payment
- Application: servicesaustralia.gov.au

=== UNITED STATES ===

**Social Security Disability Insurance (SSDI)**
- Eligibility: Worked and paid Social Security taxes, unable to work due to medical condition expected to last 12+ months or result in death
- Provides: Monthly payments based on work history
- Application: ssa.gov/applyfordisability
- Timeline: 3-5 months average
- Note: 5-month waiting period after disability begins

**Supplemental Security Income (SSI)**
- Eligibility: 65+, blind, or disabled with limited income and resources
- Provides: Monthly cash assistance
- Application: ssa.gov/ssi
- Income/asset limits apply

**Medicaid**
- Eligibility: Low income, varies significantly by state
- Provides: Health coverage including long-term care
- Application: Through state Medicaid office or healthcare.gov
- Note: Each state has different rules and benefits

**Medicare**
- Eligibility: 65+ or receiving SSDI for 24+ months
- Provides: Health insurance
- Application: ssa.gov/medicare

**Americans with Disabilities Act (ADA) Accommodations**
- Provides: Protection against discrimination, workplace accommodations
- Not a benefit program but important rights
- Information: ada.gov

=== CANADA ===

**Canada Pension Plan Disability (CPP-D)**
- Eligibility: Contributed to CPP, have severe and prolonged disability preventing regular work
- Provides: Monthly payments
- Application: canada.ca/cpp-disability
- Provincial variations exist

**Provincial Disability Programs** (examples):
- Ontario Disability Support Program (ODSP)
- Persons with Disabilities (PWD) - British Columbia
- Assured Income for the Severely Handicapped (AISH) - Alberta
- Note: Each province has different programs and eligibility

CONVERSATION APPROACH:
1. First, identify the country
2. Ask about their specific challenges (mobility, self-care, communication, cognitive, etc.)
3. Ask about their age, work situation if relevant
4. Provide 2-4 most relevant matches with clear explanations
5. Give concrete next steps

Remember: Be conversational, empathetic, and always provide the "why" behind each match.`;
}
'@
Set-Content -Path "netlify/functions/chat.js" -Value $chatJs

# Create package.json
Write-Host "Creating package.json..." -ForegroundColor Yellow
$packageJson = @'
{
  "name": "disability-connect",
  "version": "1.0.0",
  "description": "DisabilityConnect - Find disability support services",
  "main": "index.js",
  "scripts": {
    "dev": "netlify dev"
  },
  "dependencies": {
    "@anthropic-ai/sdk": "^0.32.1"
  },
  "devDependencies": {
    "netlify-cli": "^17.0.0"
  }
}
'@
Set-Content -Path "package.json" -Value $packageJson

# Create netlify.toml
Write-Host "Creating netlify.toml..." -ForegroundColor Yellow
$netlifyToml = @'
[build]
  functions = "netlify/functions"
  publish = "."

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
'@
Set-Content -Path "netlify.toml" -Value $netlifyToml

# Create .gitignore
Write-Host "Creating .gitignore..." -ForegroundColor Yellow
$gitignore = @'
node_modules/
.env
.env.local
.netlify/
.idea/
.vscode/
*.iml
.DS_Store
Thumbs.db
'@
Set-Content -Path ".gitignore" -Value $gitignore

# Create README.md
Write-Host "Creating README.md..." -ForegroundColor Yellow
$readme = @'
# DisabilityConnect

AI-powered disability support service finder.

## Setup

1. Install dependencies:
```bash
npm install
```

2. Create .env file:
```
ANTHROPIC_API_KEY=your-key-here
```

3. Run locally:
```bash
npm run dev
```

4. Open: http://localhost:8888

## Deploy to Netlify

1. Push to GitHub
2. Connect to Netlify
3. Add ANTHROPIC_API_KEY environment variable
4. Deploy
'@
Set-Content -Path "README.md" -Value $readme

# Create .env.example
Write-Host "Creating .env.example..." -ForegroundColor Yellow
$envExample = @'
ANTHROPIC_API_KEY=your-api-key-here
'@
Set-Content -Path ".env.example" -Value $envExample

Write-Host "`nProject structure created successfully!" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. npm install" -ForegroundColor White
Write-Host "2. Create .env file with your API key" -ForegroundColor White
Write-Host "3. npm run dev" -ForegroundColor White
Write-Host "`nFiles created:" -ForegroundColor Cyan
Write-Host "- index.html" -ForegroundColor White
Write-Host "- netlify/functions/chat.js" -ForegroundColor White
Write-Host "- package.json" -ForegroundColor White
Write-Host "- netlify.toml" -ForegroundColor White
Write-Host "- .gitignore" -ForegroundColor White
Write-Host "- README.md" -ForegroundColor White
Write-Host "- .env.example" -ForegroundColor White