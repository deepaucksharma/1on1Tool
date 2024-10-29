#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Create a new directory for the project and navigate into it
mkdir -p one-on-one-tool
cd one-on-one-tool

# Initialize a new React app
npx create-react-app .

# Install required dependencies
npm install react-draft-wysiwyg draft-js draftjs-to-html draft-js-export-html
npm install lucide-react
npm install tailwindcss postcss autoprefixer
npm install @headlessui/react

# Initialize Tailwind CSS
npx tailwindcss init -p

# Update Tailwind CSS configuration
cat > tailwind.config.js << 'EOL'
module.exports = {
  content: [
    './src/**/*.{js,jsx,ts,tsx}',
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
EOL

# Create index.css with Tailwind directives
cat > src/index.css << 'EOL'
@tailwind base;
@tailwind components;
@tailwind utilities;
EOL

# Update index.js
cat > src/index.js << 'EOL'
import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import App from './App';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOL

# Create components directory
mkdir -p src/components
