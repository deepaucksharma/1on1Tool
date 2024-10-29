#!/bin/bash

set -e

PROJECT_DIR="$HOME/one-on-one-tool"

# Remove existing project directory if user confirms
if [ -d "$PROJECT_DIR" ]; then
    read -p "Project directory already exists. Do you want to delete it and start fresh? [y/N]: " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
        rm -rf "$PROJECT_DIR"
    else
        echo "Installation aborted by user."
        exit 1
    fi
fi

# Create project directory and navigate into it
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Initialize a new npm project
npm init -y

# Install core dependencies
npm install react@18.2.0 react-dom@18.2.0

# Install development dependencies
npm install --save-dev typescript@5.0.4 @types/react@18.0.28 @types/react-dom@18.0.11 \
webpack@5.88.1 webpack-cli@5.1.4 webpack-dev-server@4.15.1 ts-loader@9.4.3 \
html-webpack-plugin@5.5.3 @babel/core@7.22.9 @babel/preset-env@7.22.9 \
@babel/preset-react@7.22.5 @babel/preset-typescript@7.22.5 babel-loader@9.1.3 \
style-loader@3.3.3 css-loader@6.8.1

# Create tsconfig.json for TypeScript configuration
cat > tsconfig.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES6",
    "lib": ["dom", "dom.iterable", "esnext"],
    "jsx": "react-jsx",
    "module": "ESNext",
    "moduleResolution": "node",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "allowJs": true,
    "noEmit": true
  },
  "include": ["src"],
  "exclude": ["node_modules"]
}
EOF

# Create webpack.config.js
cat > webpack.config.js <<'EOF'
const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
  entry: './src/index.tsx',
  mode: 'development',
  devtool: 'source-map', // Added for easier debugging
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'bundle.js',
    clean: true
  },
  resolve: {
    extensions: ['.tsx', '.ts', '.js'],
  },
  module: {
    rules: [
      // TypeScript and Babel loader
      {
        test: /\.(ts|tsx)$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: [
              '@babel/preset-env',
              '@babel/preset-react',
              '@babel/preset-typescript'
            ]
          }
        }
      },
      // CSS loader
      {
        test: /\.css$/,
        use: ['style-loader', 'css-loader'],
      }
    ]
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: './public/index.html',
    }),
  ],
  devServer: {
    static: {
      directory: path.join(__dirname, 'public'),
    },
    port: 3000,
    open: true,
  },
};
EOF

# Create .gitignore
cat > .gitignore <<'EOF'
node_modules/
dist/
.DS_Store
EOF

# Create directories for the project structure
mkdir -p src/components src/hooks src/constants src/types public

# Create public/index.html
cat > public/index.html <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>One-on-One Tool</title>
</head>
<body>
  <div id="root"></div>
</body>
</html>
EOF

# Create src/index.tsx
cat > src/index.tsx <<'EOF'
import React from 'react';
import { createRoot } from 'react-dom/client';
import App from './App';

const rootElement = document.getElementById('root');
if (rootElement) {
  const root = createRoot(rootElement);
  root.render(<App />);
} else {
  console.error('Root element not found!');
}
EOF

# Create src/App.tsx
cat > src/App.tsx <<'EOF'
import React from 'react';
import { PhaseNavigation } from './components/PhaseNavigation';
import { QuestionItem } from './components/QuestionItem';
import { TipsList } from './components/TipsList';
import { useTimer } from './hooks/useTimer';
import { usePhases } from './hooks/usePhases';
import { RED_FLAGS, INITIAL_TIMER } from './constants';

const App: React.FC = () => {
  const {
    timer,
    isRunning,
    startTimer,
    pauseTimer,
    resetTimer,
    formatTime,
  } = useTimer(INITIAL_TIMER);

  const {
    phases,
    activePhase,
    setActivePhase,
    completedTasks,
    toggleTaskCompletion,
    notes,
    handleNotesChange,
  } = usePhases();

  const currentPhase = phases[activePhase];

  return (
    <div style={{ padding: '20px' }}>
      <h1>One-on-One Tool</h1>
      <div>
        <span>Timer: {formatTime(timer)}</span>
        <button onClick={isRunning ? pauseTimer : startTimer}>
          {isRunning ? 'Pause' : 'Start'}
        </button>
        <button onClick={resetTimer}>Reset</button>
      </div>

      <PhaseNavigation
        phases={phases}
        activePhase={activePhase}
        onPhaseChange={setActivePhase}
      />

      <div>
        <h2>{currentPhase.title} ({currentPhase.duration})</h2>
        <ul>
          {currentPhase.questions.map((question, idx) => (
            <QuestionItem
              key={idx}
              question={question}
              isCompleted={Boolean(completedTasks[\`\${activePhase}-\${idx}\`])}
              onToggle={() => toggleTaskCompletion(activePhase, idx)}
            />
          ))}
        </ul>
        <textarea
          value={notes[activePhase]}
          onChange={(e) => handleNotesChange(activePhase, e.target.value)}
          placeholder="Add notes..."
          style={{ width: '100%', height: '100px' }}
        />
      </div>

      <div>
        <h3>Tips</h3>
        <TipsList tips={currentPhase.tips} />
      </div>

      <div>
        <h3>Red Flags to Watch For:</h3>
        <ul>
          {RED_FLAGS.map((flag, idx) => (
            <li key={idx}>{flag}</li>
          ))}
        </ul>
      </div>
    </div>
  );
};

export default App;
EOF

# Create src/hooks/useTimer.ts
cat > src/hooks/useTimer.ts <<'EOF'
import { useState, useEffect, useCallback } from 'react';

export const useTimer = (initialTime: number = 3600) => {
  const [timer, setTimer] = useState<number>(initialTime);
  const [isRunning, setIsRunning] = useState<boolean>(false);

  useEffect(() => {
    let intervalId: number | undefined;
    if (isRunning && timer > 0) {
      intervalId = window.setInterval(() => {
        setTimer((prev) => {
          if (prev <= 1) {
            setIsRunning(false);
            return 0;
          }
          return prev - 1;
        });
      }, 1000);
    }
    return () => {
      if (intervalId !== undefined) window.clearInterval(intervalId);
    };
  }, [isRunning, timer]);

  const startTimer = useCallback(() => setIsRunning(true), []);
  const pauseTimer = useCallback(() => setIsRunning(false), []);
  const resetTimer = useCallback(() => {
    setIsRunning(false);
    setTimer(initialTime);
  }, [initialTime]);

  const formatTime = useCallback((seconds: number): string => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return \`\${mins.toString().padStart(2, '0')}:\${secs.toString().padStart(2, '0')}\`;
  }, []);

  return { timer, isRunning, startTimer, pauseTimer, resetTimer, formatTime };
};
EOF

# Create src/hooks/usePhases.ts
cat > src/hooks/usePhases.ts <<'EOF'
import { useState, useCallback } from 'react';
import { PHASES_DATA } from '../constants';
import { PhaseKey, CompletedTasks, Notes } from '../types';

export const usePhases = () => {
  const [activePhase, setActivePhase] = useState<PhaseKey>('connect');
  const [completedTasks, setCompletedTasks] = useState<CompletedTasks>({});
  const [notes, setNotes] = useState<Notes>(() =>
    Object.keys(PHASES_DATA).reduce((acc, key) => ({ ...acc, [key]: '' }), {} as Notes)
  );

  const toggleTaskCompletion = useCallback((phaseKey: PhaseKey, questionIdx: number) => {
    setCompletedTasks((prev) => ({
      ...prev,
      [\`\${phaseKey}-\${questionIdx}\`]: !prev[\`\${phaseKey}-\${questionIdx}\`],
    }));
  }, []);

  const handleNotesChange = useCallback((phase: PhaseKey, value: string) => {
    setNotes((prev) => ({
      ...prev,
      [phase]: value,
    }));
  }, []);

  return {
    phases: PHASES_DATA,
    activePhase,
    setActivePhase,
    completedTasks,
    toggleTaskCompletion,
    notes,
    handleNotesChange,
  };
};
EOF

# Create src/components/PhaseNavigation.tsx
cat > src/components/PhaseNavigation.tsx <<'EOF'
import React from 'react';
import { PhaseKey } from '../types';

interface PhaseNavigationProps {
  phases: Record<PhaseKey, { title: string }>;
  activePhase: PhaseKey;
  onPhaseChange: (phase: PhaseKey) => void;
}

export const PhaseNavigation: React.FC<PhaseNavigationProps> = ({
  phases,
  activePhase,
  onPhaseChange,
}) => (
  <div style={{ marginBottom: '20px' }}>
    {Object.entries(phases).map(([key, phase]) => (
      <button
        key={key}
        onClick={() => onPhaseChange(key as PhaseKey)}
        style={{
          margin: '0 10px',
          padding: '5px 10px',
          backgroundColor: activePhase === key ? '#007bff' : '#ffffff',
          color: activePhase === key ? '#ffffff' : '#000000',
          border: '1px solid #007bff',
          borderRadius: '4px',
          cursor: 'pointer',
        }}
      >
        {phase.title}
      </button>
    ))}
  </div>
);
EOF

# Create src/components/QuestionItem.tsx
cat > src/components/QuestionItem.tsx <<'EOF'
import React from 'react';

interface QuestionItemProps {
  question: string;
  isCompleted: boolean;
  onToggle: () => void;
}

export const QuestionItem: React.FC<QuestionItemProps> = ({
  question,
  isCompleted,
  onToggle,
}) => (
  <li
    style={{
      listStyle: 'none',
      margin: '10px 0',
      cursor: 'pointer',
      display: 'flex',
      alignItems: 'center',
    }}
    onClick={onToggle}
  >
    <input
      type="checkbox"
      checked={isCompleted}
      readOnly
      style={{ marginRight: '10px' }}
    />
    <span style={{ textDecoration: isCompleted ? 'line-through' : 'none' }}>
      {question}
    </span>
  </li>
);
EOF

# Create src/components/TipsList.tsx
cat > src/components/TipsList.tsx <<'EOF'
import React from 'react';

interface TipsListProps {
  tips: string[];
}

export const TipsList: React.FC<TipsListProps> = ({ tips }) => (
  <ul style={{ paddingLeft: '20px' }}>
    {tips.map((tip, idx) => (
      <li key={idx} style={{ margin: '5px 0' }}>
        {tip}
      </li>
    ))}
  </ul>
);
EOF

# Create src/constants/index.ts
cat > src/constants/index.ts <<'EOF'
import { Phases } from '../types';

export const PHASES_DATA: Phases = {
  connect: {
    title: '1. Connect',
    duration: '5-10 min',
    questions: [
      'How are you feeling today?',
      "What's top of mind for you this week?",
      'Any wins or challenges since we last met?',
    ],
    tips: [
      'Start with a personal check-in',
      'Practice active listening',
      'Show genuine interest',
    ],
  },
  explore: {
    title: '2. Explore',
    duration: '10-15 min',
    questions: [
      "What's the biggest challenge you're facing right now?",
      'What are you most excited about in your current project?',
      'How can I best support you?',
    ],
    tips: [
      'Use open-ended questions',
      'Listen more than you speak',
      'Look for underlying themes',
    ],
  },
  structure: {
    title: '3. Structure',
    duration: '5-10 min',
    questions: [
      'What are your top priorities for this week?',
      'What resources do you need to succeed?',
      'How will we measure progress?',
    ],
    tips: [
      'Set clear expectations',
      'Define measurable outcomes',
      'Agree on next steps',
    ],
  },
  document: {
    title: '4. Document',
    duration: '5-10 min',
    questions: [
      'What are the key action items from our discussion?',
      'Who owns each action item?',
      'What are the deadlines?',
    ],
    tips: [
      'Capture specific commitments',
      'Set clear deadlines',
      'Assign owners to tasks',
    ],
  },
  grow: {
    title: '5. Grow',
    duration: '10-15 min',
    questions: [
      'What are your long-term career goals?',
      'What skills would you like to develop?',
      'How can we measure your growth?',
    ],
    tips: [
      'Focus on long-term development',
      'Identify learning opportunities',
      'Create growth metrics',
    ],
  },
};

export const RED_FLAGS = [
  'Consistently canceled meetings',
  'Surface-level responses only',
  'Avoiding difficult topics',
  'Lack of engagement',
];

export const INITIAL_TIMER = 3600; // 60 minutes in seconds
EOF

# Create src/types/index.ts
cat > src/types/index.ts <<'EOF'
export interface Phase {
  title: string;
  duration: string;
  questions: string[];
  tips: string[];
}

export type PhaseKey = 'connect' | 'explore' | 'structure' | 'document' | 'grow';

export type Phases = Record<PhaseKey, Phase>;

export type CompletedTasks = Record<string, boolean>;

export type Notes = Record<PhaseKey, string>;
EOF

# Update package.json scripts
npm pkg set scripts.start="webpack serve --mode development"
npm pkg set scripts.build="webpack --mode production"

# Install dependencies
npm install

echo "Setup complete! You can now run 'npm start' in the project directory to start the application."
