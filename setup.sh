#!/bin/bash

# Create a new directory for the project
mkdir one-on-one-tool
cd one-on-one-tool

# Initialize a new React app
npx create-react-app .

# Install required dependencies
npm install react-draft-wysiwyg draft-js draftjs-to-html
npm install lucide-react
npm install tailwindcss postcss autoprefixer
npx tailwindcss init -p

# Update Tailwind CSS configuration
echo "module.exports = {
  content: ['./src/**/*.{js,jsx,ts,tsx}'],
  theme: {
    extend: {},
  },
  plugins: [],
};" > tailwind.config.js

# Create the main application files
rm -f src/App.js src/App.css src/index.css src/logo.svg

# Create index.css
echo "@tailwind base;
@tailwind components;
@tailwind utilities;" > src/index.css

# Create App.js
cat <<EOL > src/App.js
// Paste the full code for App.js here
EOL

# Create additional components
mkdir src/components
touch src/components/RichTextEditor.js
touch src/components/TagInput.js
touch src/components/CheatSheetModal.js

# Create RichTextEditor.js
cat <<EOL > src/components/RichTextEditor.js
// Paste the full code for RichTextEditor.js here
EOL

# Create TagInput.js
cat <<EOL > src/components/TagInput.js
// Paste the full code for TagInput.js here
EOL

# Create CheatSheetModal.js
cat <<EOL > src/components/CheatSheetModal.js
// Paste the full code for CheatSheetModal.js here
EOL

# Start the development server
npm start
