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

# Install required dependencies
npm install react-draft-wysiwyg@1.14.7 draft-js@0.11.7 draftjs-to-html@0.10.4 draft-js-export-html@1.4.1 dompurify@3.0.6 \
  lucide-react@0.264.0 tailwindcss@3.2.7 postcss@8.4.21 autoprefixer@10.4.13 @headlessui/react@1.7.14 @heroicons/react@2.0.18 uuid || {
    echo "Dependency installation failed. Aborting.";
    exit 1;
}

# Initialize Tailwind CSS
npx tailwindcss init -p

# Update Tailwind CSS configuration
cat > tailwind.config.js <<EOL
// tailwind.config.js
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

# Create constants.js
cat > src/constants.js <<'EOL'
// src/constants.js
export const defaultPhases = [
  {
    id: 'connect',
    title: 'Connect',
    duration: '5-10 min',
    purpose: 'Build trust and rapport',
    principle: 'Build Trust',
    essentialActions: ['Actively listen', 'Be present', 'Be open'],
    questions: [
      {
        text: 'How are you feeling today?',
        categories: ['Well-being', 'Relationship'],
      },
      {
        text: "What's top of mind for you this week?",
        categories: ['Well-being', 'Performance'],
      },
    ],
    tips: ['Start with a personal check-in to build rapport', 'Practice active listening'],
    redFlags: [],
  },
  {
    id: 'explore',
    title: 'Explore',
    duration: '10-15 min',
    purpose: 'Understand needs, challenges, and motivations',
    principle: 'Understand Needs',
    essentialActions: ['Identify challenges', 'Uncover motivations', 'Offer support'],
    questions: [
      {
        text: "What's the biggest challenge you're facing right now?",
        categories: ['Performance', 'Support'],
      },
      {
        text: 'How can I best support you?',
        categories: ['Support', 'Relationship'],
      },
    ],
    tips: ['Use open-ended questions', 'Identify challenges early', 'Offer concrete support'],
    redFlags: ['Signs of disengagement or burnout', 'Lack of progress on key tasks'],
  },
];

export const allCategories = [
  'Performance',
  'Well-being',
  'Growth',
  'Relationship',
  'Support',
  'Accountability',
  'Clarity',
  'Time Management',
  'Resources',
  'Other',
];
EOL

# Create hooks directory and useLocalStorage.js
mkdir -p src/hooks
cat > src/hooks/useLocalStorage.js <<'EOL'
// src/hooks/useLocalStorage.js
import { useState, useEffect } from 'react';

export function useLocalStorage(key, initialValue, options = {}) {
  const [storedValue, setStoredValue] = useState(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item !== null ? JSON.parse(item) : initialValue;
    } catch (error) {
      console.error(`Error parsing localStorage key "${key}":`, error);
      return options.fallback || initialValue;
    }
  });

  const setValue = (value) => {
    try {
      const valueToStore =
        value instanceof Function ? value(storedValue) : value;
      setStoredValue(valueToStore);
      window.localStorage.setItem(key, JSON.stringify(valueToStore));
    } catch (error) {
      console.error(`Error setting localStorage key "${key}":`, error);
      if (options.onError) options.onError(error);
    }
  };

  useEffect(() => {
    const handleStorageChange = (event) => {
      if (event.key === key) {
        setStoredValue(JSON.parse(event.newValue) || initialValue);
      }
    };

    window.addEventListener('storage', handleStorageChange);
    return () => window.removeEventListener('storage', handleStorageChange);
  }, [key]);

  return [storedValue, setValue];
}
EOL


# Create components directory and files
mkdir -p src/components

# Create ErrorBoundary.js
cat > src/components/ErrorBoundary.js <<'EOL'
// src/components/ErrorBoundary.js
import React from 'react';

class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true };
  }

  componentDidCatch(error, errorInfo) {
    console.error('Uncaught error:', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return <h1>Something went wrong.</h1>;
    }
    return this.props.children; 
  }
}

export default ErrorBoundary;
EOL

# Create RichTextEditor.js
cat > src/components/RichTextEditor.js <<'EOL'
// src/components/RichTextEditor.js
import React, { useState, useEffect } from 'react';
import {
  EditorState,
  convertToRaw,
  ContentState,
  convertFromHTML,
} from 'draft-js';
import { Editor } from 'react-draft-wysiwyg';
import draftToHtml from 'draftjs-to-html';
import DOMPurify from 'dompurify';

import 'react-draft-wysiwyg/dist/react-draft-wysiwyg.css';

export default function RichTextEditor({ content, onChange }) {
  const [editorState, setEditorState] = useState(() =>
    content
      ? EditorState.createWithContent(
          ContentState.createFromBlockArray(convertFromHTML(content))
        )
      : EditorState.createEmpty()
  );

  useEffect(() => {
    if (content) {
      const blocksFromHTML = convertFromHTML(content);
      const newState = ContentState.createFromBlockArray(
        blocksFromHTML.contentBlocks,
        blocksFromHTML.entityMap
      );
      setEditorState(EditorState.createWithContent(newState));
    } else {
      setEditorState(EditorState.createEmpty());
    }
  }, [content]);

  const handleEditorChange = (state) => {
    setEditorState(state);
    const rawContentState = convertToRaw(state.getCurrentContent());
    const htmlContent = draftToHtml(rawContentState);
    const sanitizedContent = DOMPurify.sanitize(htmlContent);
    onChange(sanitizedContent);
  };

  return (
    <div className="border p-2 rounded">
      <Editor
        editorState={editorState}
        onEditorStateChange={handleEditorChange}
        toolbar={{
          options: ['inline', 'list', 'textAlign', 'link', 'blockType'],
          inline: { options: ['bold', 'italic', 'underline'] },
          list: { options: ['unordered', 'ordered'] },
        }}
        editorClassName="min-h-[150px]"
      />
    </div>
  );
}
EOL

# Create TagInput.js
cat > src/components/TagInput.js <<'EOL'
// src/components/TagInput.js
import React, { useState, useCallback, useEffect } from 'react';

export default function TagInput({ availableTags, selectedTags, onChange }) {
  const [pendingTags, setPendingTags] = useState(selectedTags);

  const handleTagClick = useCallback((tag) => {
    setPendingTags((prevTags) =>
      prevTags.includes(tag)
        ? prevTags.filter((t) => t !== tag)
        : [...prevTags, tag]
    );
  }, []);

  useEffect(() => {
    const handler = setTimeout(() => {
      onChange(pendingTags);
    }, 200); // Debounce time in milliseconds

    return () => {
      clearTimeout(handler);
    };
  }, [pendingTags, onChange]);

  return (
    <div className="flex flex-wrap gap-2">
      {availableTags.map((tag) => (
        <button
          key={tag}
          onClick={() => handleTagClick(tag)}
          className={`px-3 py-1 rounded-full text-sm ${
            pendingTags.includes(tag)
              ? 'bg-blue-500 text-white'
              : 'bg-gray-100 hover:bg-gray-200'
          }`}
        >
          {tag}
        </button>
      ))}
    </div>
  );
}
EOL

# Create CheatSheetModal.js
cat > src/components/CheatSheetModal.js <<'EOL'
// src/components/CheatSheetModal.js
import React, { useEffect, useRef } from 'react';
import { X } from 'lucide-react';

export default function CheatSheetModal({ phase, onClose }) {
  const modalRef = useRef(null);

  useEffect(() => {
    const handleEscape = (e) => {
      if (e.key === 'Escape') onClose();
    };
    document.addEventListener('keydown', handleEscape);
    return () => document.removeEventListener('keydown', handleEscape);
  }, [onClose]);

  const handleOverlayClick = (e) => {
    if (modalRef.current && modalRef.current === e.target) {
      e.stopPropagation();
      onClose();
    }
  };

  return (
    <div
      ref={modalRef}
      onClick={handleOverlayClick}
      className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
    >
      <div
        className="bg-white rounded-lg shadow-lg max-w-md w-full p-6 relative"
        role="dialog"
        aria-modal="true"
        onClick={(e) => e.stopPropagation()}
      >
        <button
          onClick={onClose}
          className="absolute top-2 right-2 text-gray-500 hover:text-gray-700"
        >
          <X className="w-5 h-5" />
        </button>
        <h2 className="text-xl font-semibold mb-4">{phase.title} Cheat Sheet</h2>
        <p className="text-sm mb-2">
          <strong>Principle:</strong> {phase.principle}
        </p>
        <p className="text-sm mb-2">
          <strong>Essential Actions:</strong>
        </p>
        <ul className="list-disc list-inside text-sm mb-4">
          {phase.essentialActions.map((action, i) => (
            <li key={i}>{action}</li>
          ))}
        </ul>
        <p className="text-sm mb-2">
          <strong>Suggested Questions:</strong>
        </p>
        <ul className="list-disc list-inside text-sm">
          {phase.questions.map((q, i) => (
            <li key={i}>{q.text}</li>
          ))}
        </ul>
      </div>
    </div>
  );
}
EOL

# Create App.js with your updated code
cat > src/App.js <<'EOL'
// src/App.js
import React, { useState, useCallback } from 'react';
import { v4 as uuidv4 } from 'uuid';
import { Clock, Info } from 'lucide-react';
import { useLocalStorage } from './hooks/useLocalStorage';
import { defaultPhases, allCategories } from './constants';
import RichTextEditor from './components/RichTextEditor';
import TagInput from './components/TagInput';
import CheatSheetModal from './components/CheatSheetModal';

export default function App() {
  const [notes, setNotes] = useLocalStorage('oneOnOneNotes', {});
  const [activePhase, setActivePhase] = useState(defaultPhases[0]);
  const [showCheatSheet, setShowCheatSheet] = useState(false);
  const [selectedTags, setSelectedTags] = useLocalStorage('selectedTags', []);

  const handleNoteChange = useCallback(
    (content) => {
      setNotes((prevNotes) => ({
        ...prevNotes,
        [activePhase.id]: content,
      }));
    },
    [activePhase.id, setNotes]
  );

  const handleTagChange = useCallback(
    (newTags) => {
      setSelectedTags(newTags);
    },
    [setSelectedTags]
  );

  const handlePhaseChange = useCallback(
    (phase) => {
      setActivePhase(phase);
      setShowCheatSheet(false);
    },
    []
  );

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white shadow">
        <div className="max-w-7xl mx-auto px-4 py-6 sm:px-6 lg:px-8">
          <h1 className="text-3xl font-bold text-gray-900">1:1 Meeting Tool</h1>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="bg-white rounded-lg shadow p-6">
          {/* Phase Navigation */}
          <div className="flex space-x-4 mb-8 overflow-x-auto">
            {defaultPhases.map((phase) => (
              <button
                key={phase.id}
                onClick={() => handlePhaseChange(phase)}
                className={`px-4 py-2 rounded-md flex items-center space-x-2 ${
                  activePhase.id === phase.id
                    ? 'bg-blue-500 text-white'
                    : 'bg-gray-100 hover:bg-gray-200 text-gray-700'
                }`}
              >
                <span>{phase.title}</span>
                <Clock className="w-4 h-4" />
                <span className="text-sm">{phase.duration}</span>
              </button>
            ))}
          </div>

          {/* Active Phase Content */}
          <div className="space-y-6">
            <div className="flex justify-between items-center">
              <h2 className="text-xl font-semibold">{activePhase.title} Phase</h2>
              <button
                onClick={() => setShowCheatSheet(true)}
                className="flex items-center space-x-1 text-blue-500 hover:text-blue-600"
              >
                <Info className="w-4 h-4" />
                <span>View Cheat Sheet</span>
              </button>
            </div>

            <div className="space-y-4">
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

# Run build to verify if the setup works
npm run build || { echo "Build failed, please check for syntax errors."; exit 1; }

# Start the development server
npm start
