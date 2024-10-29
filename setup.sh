#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -euo pipefail

# Check if the directory already exists
if [ -d "one-on-one-tool" ]; then
    echo "Directory 'one-on-one-tool' already exists. Please remove it or choose a different name."
    exit 1
fi

# Trap to clean up in case of errors
trap 'echo "An error occurred. Cleaning up..."; rm -rf one-on-one-tool; exit 1' ERR

# Create a new directory for the project and navigate into it
mkdir -p one-on-one-tool
cd one-on-one-tool

# Initialize a new React app (using the PWA template)
npx create-react-app . --template cra-template-pwa

# Update package.json dependencies and scripts
cat > package.json <<EOL
{
  "dependencies": {
    "@headlessui/react": "^1.7.14",
    "@heroicons/react": "^2.0.18",
    "autoprefixer": "^10.4.13",
    "dompurify": "^3.0.6",
    "draft-js": "^0.11.7",
    "draft-js-export-html": "^1.4.1",
    "draftjs-to-html": "^0.10.4",
    "lucide-react": "^0.264.0",
    "postcss": "^8.4.21",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-draft-wysiwyg": "^1.15.0",
    "react-scripts": "5.0.1",
    "tailwindcss": "^3.2.7",
    "uuid": "^9.0.0"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject"
  }
}
EOL

# Install updated dependencies
npm install || { echo "Dependency installation failed. Aborting."; exit 1; }

# Initialize Tailwind CSS
npx tailwindcss init -p

# Update Tailwind CSS configuration
cat > tailwind.config.js <<EOL
module.exports = {
  content: ['./src/**/*.{js,jsx,ts,tsx}'],
  theme: {
    extend: {
      colors: {
        primary: '#1d4ed8',
        secondary: '#9333ea',
      },
      spacing: {
        '128': '32rem',
      },
    },
  },
  plugins: [],
  // Important: Add this to prevent conflicts with the rich text editor
  important: true,
  // Add this to handle the editor's wrapper class
  safelist: [
    'rdw-editor-wrapper',
    'rdw-editor-toolbar',
    'public-DraftStyleDefault-block'
  ]
};
EOL

# Remove unnecessary files
for file in src/App.css src/logo.svg src/App.test.js src/reportWebVitals.js src/setupTests.js; do
  if [ -f "$file" ]; then
    rm "$file"
  fi
done

# Create index.css
cat > src/index.css <<EOL
/* src/index.css */
@tailwind base;
@tailwind components;
@tailwind utilities;

/* Animation keyframes */
@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes scaleIn {
  from { 
    opacity: 0;
    transform: scale(0.95);
  }
  to { 
    opacity: 1;
    transform: scale(1);
  }
}

/* Custom animation classes */
.animate-fadeIn {
  animation: fadeIn 0.2s ease-out;
}

.animate-scaleIn {
  animation: scaleIn 0.2s ease-out;
}

/* Rich text editor overrides */
.rdw-editor-wrapper {
  background-color: white;
}

.rdw-editor-toolbar {
  border-bottom: 1px solid #e5e7eb;
  margin-bottom: 0;
  padding: 0.5rem;
}

.rdw-option-wrapper {
  border: 1px solid #e5e7eb;
  padding: 0.25rem;
}

.rdw-option-active {
  background-color: #eff6ff;
  border-color: #3b82f6;
}

.public-DraftStyleDefault-block {
  margin: 0.5rem 0;
}
EOL

# Update index.js
cat > src/index.js <<EOL
// src/index.js
import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import App from './App';
import ErrorBoundary from './components/ErrorBoundary';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    <ErrorBoundary>
      <App />
    </ErrorBoundary>
  </React.StrictMode>
);
EOL

# Create updated App.js
cat > src/App.js <<'EOL'
import React, { useState, useCallback, useEffect, useMemo } from 'react';
import { Clock, Info, Save, AlertTriangle } from 'lucide-react';
import { useLocalStorage } from './hooks/useLocalStorage';
import { defaultPhases, allCategories } from './constants';
import RichTextEditor from './components/RichTextEditor';
import TagInput from './components/TagInput';
import CheatSheetModal from './components/CheatSheetModal';

const useAutoSave = (key, value, delay = 1000) => {
  const [savedValue, setSavedValue] = useLocalStorage(key, value);
  const [isSaving, setIsSaving] = useState(false);
  const [lastSaved, setLastSaved] = useState(null);

  useEffect(() => {
    const timer = setTimeout(() => {
      setIsSaving(true);
      try {
        setSavedValue(value);
        setLastSaved(new Date());
      } catch (error) {
        console.error('Error saving data:', error);
      } finally {
        setIsSaving(false);
      }
    }, delay);

    return () => clearTimeout(timer);
  }, [value, delay, setSavedValue]);

  return { isSaving, lastSaved };
};

const Alert = ({ message, type = 'info' }) => (
  <div className={`rounded-md p-4 mb-4 ${
    type === 'error' ? 'bg-red-50 text-red-700' : 'bg-blue-50 text-blue-700'
  }`}>
    <div className="flex items-center">
      {type === 'error' ? (
        <AlertTriangle className="h-5 w-5 mr-2" />
      ) : (
        <Info className="h-5 w-5 mr-2" />
      )}
      <span>{message}</span>
    </div>
  </div>
);

export default function App() {
  const [notes, setNotes] = useState({});
  const [activePhase, setActivePhase] = useState(defaultPhases[0]);
  const [showCheatSheet, setShowCheatSheet] = useState(false);
  const [selectedTags, setSelectedTags] = useState([]);
  const [error, setError] = useState(null);

  // Load initial data from localStorage
  useEffect(() => {
    try {
      const savedNotes = localStorage.getItem('oneOnOneNotes');
      const savedTags = localStorage.getItem('selectedTags');
      
      if (savedNotes) setNotes(JSON.parse(savedNotes));
      if (savedTags) setSelectedTags(JSON.parse(savedTags));
    } catch (err) {
      console.error('Error loading saved data:', err);
      setError('There was an error loading your saved data. Some content might be missing.');
    }
  }, []);

  // Auto-save functionality
  const { isSaving, lastSaved } = useAutoSave('oneOnOneNotes', notes);

  const handleNoteChange = useCallback((content) => {
    setNotes(prevNotes => ({
      ...prevNotes,
      [activePhase.id]: content
    }));
  }, [activePhase.id]);

  const handleTagChange = useCallback((newTags) => {
    setSelectedTags(newTags);
    try {
      localStorage.setItem('selectedTags', JSON.stringify(newTags));
    } catch (err) {
      console.error('Error saving tags:', err);
      setError('Failed to save tags. Please try again.');
    }
  }, []);

  const handlePhaseChange = useCallback((phase) => {
    setActivePhase(phase);
    setShowCheatSheet(false);
  }, []);

  // Memoize filtered questions based on selected tags
  const filteredQuestions = useMemo(() => {
    if (!selectedTags.length) return activePhase.questions;
    return activePhase.questions.filter(q => 
      q.categories.some(cat => selectedTags.includes(cat))
    );
  }, [activePhase.questions, selectedTags]);

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 py-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center">
            <h1 className="text-2xl font-bold text-gray-900">1:1 Meeting Tool</h1>
            <div className="flex items-center space-x-2 text-sm text-gray-500">
              {isSaving ? (
                <span className="flex items-center">
                  <Save className="w-4 h-4 mr-1 animate-spin" />
                  Saving...
                </span>
              ) : lastSaved && (
                <span className="flex items-center">
                  Last saved: {new Intl.DateTimeFormat('en-US', {
                    hour: 'numeric',
                    minute: 'numeric'
                  }).format(lastSaved)}
                </span>
              )}
            </div>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {error && (
          <Alert message={error} type="error" />
        )}

        <div className="bg-white rounded-lg shadow-sm">
          {/* Phase Navigation */}
          <div className="border-b border-gray-200 px-4 py-3">
            <div className="flex space-x-4 overflow-x-auto">
              {defaultPhases.map((phase) => (
                <button
                  key={phase.id}
                  onClick={() => handlePhaseChange(phase)}
                  className={`
                    px-4 py-2 rounded-md flex items-center space-x-2 whitespace-nowrap
                    transition-colors duration-200
                    ${activePhase.id === phase.id
                      ? 'bg-blue-500 text-white'
                      : 'bg-gray-50 hover:bg-gray-100 text-gray-700'
                    }
                  `}
                >
                  <span>{phase.title}</span>
                  <div className="flex items-center text-sm">
                    <Clock className="w-4 h-4 mr-1" />
                    <span>{phase.duration}</span>
                  </div>
                </button>
              ))}
            </div>
          </div>

          {/* Active Phase Content */}
          <div className="p-6 space-y-6">
            <div className="flex justify-between items-center">
              <div>
                <h2 className="text-xl font-semibold text-gray-900">
                  {activePhase.title} Phase
                </h2>
                <p className="text-sm text-gray-500 mt-1">
                  {activePhase.purpose}
                </p>
              </div>
              <button
                onClick={() => setShowCheatSheet(true)}
                className="flex items-center space-x-1 text-blue-600 hover:text-blue-700"
              >
                <Info className="w-4 h-4" />
                <span>View Cheat Sheet</span>
              </button>
            </div>

            <div className="space-y-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Categories
                </label>
                <TagInput
                  availableTags={allCategories}
                  selectedTags={selectedTags}
                  onChange={handleTagChange}
                />
              </div>

              {filteredQuestions.length > 0 && (
                <div className="bg-gray-50 rounded-lg p-4">
                  <h3 className="text-sm font-medium text-gray-700 mb-2">
                    Suggested Questions
                  </h3>
                  <ul className="space-y-2">
                    {filteredQuestions.map((q, idx) => (
                      <li key={idx} className="text-sm text-gray-600">
                        • {q.text}
                      </li>
                    ))}
                  </ul>
                </div>
              )}

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Notes
                </label>
                <RichTextEditor
                  content={notes[activePhase.id] || ''}
                  onChange={handleNoteChange}
                />
              </div>
            </div>
          </div>
        </div>

        {/* Cheat Sheet Modal */}
        {showCheatSheet && (
          <CheatSheetModal
            phase={activePhase}
            onClose={() => setShowCheatSheet(false)}
          />
        )}
      </main>
    </div>
  );
}
EOL

# Create updated useAutoSave.js
cat > src/hooks/useAutoSave.js <<'EOL'
import { useState, useEffect } from 'react';
import { useLocalStorage } from './useLocalStorage';

export function useAutoSave(key, value, options = {}) {
  const {
    delay = 1000,
    onSave,
    onError,
  } = options;

  const [savedValue, setSavedValue] = useLocalStorage(key, value);
  const [status, setStatus] = useState('idle');
  const [lastSaved, setLastSaved] = useState(null);
  const [error, setError] = useState(null);

  useEffect(() => {
    const timer = setTimeout(() => {
      setStatus('saving');
      try {
        setSavedValue(value);
        setLastSaved(new Date());
        setStatus('saved');
        setError(null);
        if (onSave) onSave(value);
      } catch (err) {
        console.error(`Error saving to ${key}:`, err);
        setStatus('error');
        setError(err);
        if (onError) onError(err);
      }
    }, delay);

    return () => clearTimeout(timer);
  }, [key, value, delay, setSavedValue, onSave, onError]);

  return {
    status,
    lastSaved,
    error,
    savedValue,
  };
}
EOL

# Run build to verify if the setup works
npm run build || { echo "Build failed, please check for syntax errors."; exit 1; }

# Start the development server
npm start
