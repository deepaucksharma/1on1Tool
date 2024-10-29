#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Create a new directory for the project and navigate into it
mkdir -p one-on-one-tool
cd one-on-one-tool

# Initialize a new React app
npx create-react-app . --template cra-template-pwa

# Install required dependencies
npm install react-draft-wysiwyg draft-js draftjs-to-html draft-js-export-html
npm install lucide-react
npm install tailwindcss postcss autoprefixer
npm install @headlessui/react
npm install @heroicons/react

# Initialize Tailwind CSS
npx tailwindcss init -p

# Update Tailwind CSS configuration
echo "module.exports = {
  content: ['./src/**/*.{js,jsx,ts,tsx}'],
  theme: {
    extend: {},
  },
  plugins: [],
};" > tailwind.config.js

# Remove default files
rm -f src/App.css src/index.css src/logo.svg src/App.test.js src/reportWebVitals.js src/setupTests.js

# Create index.css
echo "@tailwind base;
@tailwind components;
@tailwind utilities;" > src/index.css

# Create index.js
echo "import React from 'react';
import ReactDOM from 'react-dom';
import App from './App';
import './index.css';

ReactDOM.render(<App />, document.getElementById('root'));" > src/index.js

# Create components directory
mkdir -p src/components

# Create base files
touch src/App.js
touch src/components/RichTextEditor.js
touch src/components/TagInput.js
touch src/components/CheatSheetModal.js

# Start the development server in the background
npm start &
