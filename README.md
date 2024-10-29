# One-on-One Meeting Tool

This repository contains a React-based One-on-One Meeting Tool designed to help managers conduct effective and structured one-on-one meetings with their team members. The tool integrates a cheat sheet framework to guide managers through different phases of the meeting and ensure crucial topics are covered.

Phase	Principle	Essential Actions (20%)	Example Questions
Connect	Build Trust	- Actively Listen: Pay close attention, ask clarifying questions, and reflect back what you hear.
- Be Present: Minimize distractions, maintain eye contact, and show genuine interest.
- Be Open: Share brief, relevant personal anecdotes to foster connection.	- "How are you feeling today?"
- "What's top of mind for you this week?"
- "I experienced something similar recently..."
Explore	Understand Needs	- Identify Challenges: Ask about current roadblocks and frustrations.
- Uncover Motivations: Explore their interests, goals, and what excites them about their work.
- Offer Support: Ask how you can help them succeed.	- "What's the biggest challenge you're facing right now?"
- "What are you most excited about in your current project?"
- "How can I best support you?"
Structure	Optimize Time	- Set a Clear Agenda: Collaboratively create an agenda with key topics.
- Prioritize Topics: Focus on the most important items first.
- Timebox Discussions: Allocate specific time slots for each topic to stay on track.	- "What are the most important things we need to discuss today?"
- "Let's aim to spend 15 minutes on this topic."
- "Is there anything else we need to cover before we wrap up?"
Document	Ensure Clarity	- Capture Key Decisions: Clearly record any decisions made during the meeting.
- Assign Action Items: Identify specific tasks, assign owners, and set deadlines.
- Share Notes: Use a shared document for transparency and follow-up.	- "Let's make sure we capture that decision."
- "Can you take ownership of that action item?"
- "What's a realistic deadline for completing this?"
Grow	Facilitate Development	- Discuss Aspirations: Ask about their career goals and how you can help achieve them.
- Provide Feedback: Offer specific, constructive feedback on their performance.
- Identify Resources: Suggest relevant training, mentorship, or development opportunities.	- "What are your long-term career goals?"
- "I've noticed you're excelling in this area. How can we build on that?"
- "Have you considered this course to help develop that skill?"

## Features

* **Customizable Phases:** Define meeting phases aligned with your team's needs and the cheat sheet principles.
* **Question and Response Categorization:** Categorize questions and notes for easier analysis and follow-up.
* **Rich Text Note-Taking:** Use a rich text editor to capture detailed and formatted meeting notes.
* **Contextual Tips and Red Flags:** Access tips and red flags relevant to each phase for improved meeting effectiveness.
* **Cheat Sheet Integration:** View the cheat sheet directly within the tool for guidance during the meeting.
* **Action Items:** Create and track action items with assigned owners and deadlines.
* **Category Filtering:** Filter questions and notes by category to focus on specific areas.

## Getting Started

### Prerequisites

* Node.js and npm
* Code Editor (e.g., VS Code)

### Installation

1. Clone the repository: `git clone https://github.com/your-username/one-on-one-meeting-tool.git`
2. Navigate to the project directory: `cd one-on-one-meeting-tool`
3. Install dependencies: `npm install`

### Running the Tool Locally

1. Start the development server: `npm start`
2. Open your web browser and navigate to `http://localhost:3000`

### Running with Single Click on macOS

1. Make `run.sh` executable: `chmod +x run.sh`
2. Double-click `run.sh` in Finder or run it from Terminal: `./run.sh`

## Deployment

To deploy the tool to a web server or hosting platform, follow these steps:

1. Build the production-ready version: `npm run build`
2. Deploy the contents of the `build` folder to your chosen hosting environment.

## Technologies Used

* React
* React Draft Wysiwyg
* Lucide React Icons

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bug reports and feature suggestions.

## License

This project is licensed under the MIT License.
