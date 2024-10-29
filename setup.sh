#!/bin/bash

# one-on-one-installer.sh

# Exit immediately if a command exits with a non-zero status
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print status messages
print_status() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}==>${NC} $1"
}

print_error() {
    echo -e "${RED}==>${NC} $1"
}

# Function to check command existence
check_command() {
    if ! command -v "$1" &> /dev/null; then
        print_error "Required command '$1' is not installed."
        return 1
    fi
    return 0
}

# Function to check Node.js version
check_node_version() {
    local min_version="14.0.0"
    local max_version="18.0.0"
    local current_version=$(node -v | cut -d 'v' -f 2)

    if [[ "$(printf '%s\n' "$min_version" "$current_version" | sort -V | head -n1)" != "$min_version" ]] || \
       [[ "$(printf '%s\n' "$max_version" "$current_version" | sort -V | tail -n1)" != "$max_version" ]]; then
        print_error "Node.js version must be >= $min_version and < $max_version. Current version: $current_version"
        return 1
    fi
    return 0
}

# Check if Node.js and npm are installed
check_command node || {
    print_error "Node.js is not installed. Please install Node.js version >=14.0.0 and <18.0.0."
    exit 1
}

check_node_version || {
    exit 1
}

check_command npm || {
    print_error "npm is not installed. Please install npm."
    exit 1
}
# Create project directory
PROJECT_DIR="$HOME/one-on-one-tool"
print_status "Setting up project in $PROJECT_DIR"

# Prompt before deleting existing directory
if [ -d "$PROJECT_DIR" ]; then
    read -p "Project directory already exists. Do you want to delete it and start fresh? [y/N]: " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
        rm -rf "$PROJECT_DIR" || {
            print_error "Failed to delete existing project directory"
            exit 1
        }
    else
        print_error "Installation aborted by user."
        exit 1
    fi
fi

mkdir -p "$PROJECT_DIR"

cd "$PROJECT_DIR"
# Initialize new React project
print_status "Creating new React project..."
npx create-react-app . --template typescript

# Install dependencies
print_status "Installing dependencies..."
npm install \
    @headlessui/react \
    @radix-ui/react-alert-dialog \
    class-variance-authority \
    clsx \
    lucide-react \
    tailwind-merge \
    tailwindcss \
    @tailwindcss/forms \
    @tailwindcss/typography

# Install dev dependencies
print_status "Installing dev dependencies..."
npm install --save-dev \
    @types/node \
    @types/react \
    @types/react-dom \
    autoprefixer \
    postcss \
    typescript
# Initialize Tailwind CSS
print_status "Setting up Tailwind CSS..."
npx tailwindcss init -p

# Update Tailwind config
print_status "Configuring Tailwind CSS..."
cat > tailwind.config.js <<'EOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{js,jsx,ts,tsx}",
  ],
  darkMode: 'class', // Enable dark mode
  theme: {
    extend: {
      colors: {
        border: "hsl(var(--border) / <alpha-value>)",
        input: "hsl(var(--input) / <alpha-value>)",
        ring: "hsl(var(--ring) / <alpha-value>)",
        background: "hsl(var(--background) / <alpha-value>)",
        foreground: "hsl(var(--foreground) / <alpha-value>)",
        primary: {
          DEFAULT: "hsl(var(--primary) / <alpha-value>)",
          foreground: "hsl(var(--primary-foreground) / <alpha-value>)",
        },
        secondary: {
          DEFAULT: "hsl(var(--secondary) / <alpha-value>)",
          foreground: "hsl(var(--secondary-foreground) / <alpha-value>)",
        },
        destructive: {
          DEFAULT: "hsl(var(--destructive) / <alpha-value>)",
          foreground: "hsl(var(--destructive-foreground) / <alpha-value>)",
        },
        muted: {
          DEFAULT: "hsl(var(--muted) / <alpha-value>)",
          foreground: "hsl(var(--muted-foreground) / <alpha-value>)",
        },
        accent: {
          DEFAULT: "hsl(var(--accent) / <alpha-value>)",
          foreground: "hsl(var(--accent-foreground) / <alpha-value>)",
        },
        popover: {
          DEFAULT: "hsl(var(--popover) / <alpha-value>)",
          foreground: "hsl(var(--popover-foreground) / <alpha-value>)",
        },
        card: {
          DEFAULT: "hsl(var(--card) / <alpha-value>)",
          foreground: "hsl(var(--card-foreground) / <alpha-value>)",
        },
      },
      borderRadius: {
        lg: "var(--radius)",
        md: "calc(var(--radius) - 2px)",
        sm: "calc(var(--radius) - 4px)",
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
  ],
}
EOF
# Create src/index.css
print_status "Creating index.css..."
cat > src/index.css <<'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;

    --card: 0 0% 100%;
    --card-foreground: 222.2 84% 4.9%;

    --popover: 0 0% 100%;
    --popover-foreground: 222.2 84% 4.9%;

    --primary: 222.2 47.4% 11.2%;
    --primary-foreground: 210 40% 98%;

    --secondary: 210 40% 96.1%;
    --secondary-foreground: 222.2 47.4% 11.2%;

    --muted: 210 40% 96.1%;
    --muted-foreground: 215.4 16.3% 46.9%;

    --accent: 210 40% 96.1%;
    --accent-foreground: 222.2 47.4% 11.2%;

    --destructive: 0 84.2% 60.2%;
    --destructive-foreground: 210 40% 98%;

    --border: 214.3 31.8% 91.4%;
    --input: 214.3 31.8% 91.4%;
    --ring: 222.2 84% 4.9%;

    --radius: 0.5rem;
  }

  .dark {
    --background: 222.2 84% 4.9%;
    --foreground: 210 40% 98%;

    --card: 222.2 84% 4.9%;
    --card-foreground: 210 40% 98%;

    --popover: 222.2 84% 4.9%;
    --popover-foreground: 210 40% 98%;

    --primary: 210 40% 98%;
    --primary-foreground: 222.2 47.4% 11.2%;

    --secondary: 217.2 32.6% 17.5%;
    --secondary-foreground: 210 40% 98%;

    --muted: 217.2 32.6% 17.5%;
    --muted-foreground: 215 20.2% 65.1%;

    --accent: 217.2 32.6% 17.5%;
    --accent-foreground: 210 40% 98%;

    --destructive: 0 62.8% 30.6%;
    --destructive-foreground: 210 40% 98%;

    --border: 217.2 32.6% 17.5%;
    --input: 217.2 32.6% 17.5%;
    --ring: 212.7 26.8% 83.9%;
  }

  body {
    @apply bg-background text-foreground;
  }

  * {
    @apply border-border;
  }
}
EOF
# Update src/index.tsx
print_status "Updating index.tsx..."
cat > src/index.tsx <<'EOF'
import React from 'react';
import { createRoot } from 'react-dom/client';
import './index.css';
import App from './App';

const container = document.getElementById('root');
if (!container) throw new Error('Failed to find the root element');
const root = createRoot(container);

root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOF
# Remove default App files if they exist
[ -f src/App.css ] && rm src/App.css
[ -f src/App.test.tsx ] && rm src/App.test.tsx
[ -f src/logo.svg ] && rm src/logo.svg
[ -f src/reportWebVitals.ts ] && rm src/reportWebVitals.ts
[ -f src/setupTests.ts ] && rm src/setupTests.ts
# Create src/App.tsx
print_status "Creating src/App.tsx..."
cat > src/App.tsx <<'EOF'
import React, { useMemo } from 'react';
import { Clock, AlertCircle } from 'lucide-react';
import { Card, CardHeader, CardTitle, CardContent } from './components/ui/card';
import { Alert, AlertDescription } from './components/ui/alert';
import { PhaseNavigation } from './components/PhaseNavigation';
import { QuestionItem } from './components/QuestionItem';
import { TipsList } from './components/TipsList';
import { useTimer } from './hooks/useTimer';
import { usePhases } from './hooks/usePhases';
import { RED_FLAGS, INITIAL_TIMER } from './constants';
import type { PhaseKey } from './types';
import { ErrorBoundary } from './components/ErrorBoundary';

const App: React.FC = () => {
  // ... (Include the full content of App component as provided in the previous response)
};

export default App;
EOF
# Update package.json
print_status "Updating package.json..."
cat > package.json <<'EOF'
{
  "name": "one-on-one-tool",
  "version": "0.1.0",
  "private": true,
  "dependencies": {
    "@headlessui/react": "^1.7.17",
    "@radix-ui/react-alert-dialog": "^1.0.5",
    "class-variance-authority": "^0.7.0",
    "clsx": "^2.0.0",
    "lucide-react": "^0.284.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-scripts": "5.0.1",
    "tailwind-merge": "^1.14.0",
    "tailwindcss": "^3.3.3"
  },
  "devDependencies": {
    "@types/node": "^18.17.1",
    "@types/react": "^18.2.18",
    "@types/react-dom": "^18.2.7",
    "autoprefixer": "^10.4.16",
    "postcss": "^8.4.31",
    "typescript": "^4.9.5",
    "@testing-library/jest-dom": "^5.17.0",
    "@testing-library/react": "^13.4.0",
    "@testing-library/user-event": "^13.5.0",
    "@tailwindcss/forms": "^0.5.9",
    "@tailwindcss/typography": "^0.5.9"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test --watchAll=false",
    "eject": "react-scripts eject"
  },
  "eslintConfig": {
    "extends": ["react-app", "react-app/jest"]
  },
  "browserslist": {
    "production": [">0.2%", "not dead", "not op_mini all"],
    "development": ["last 1 chrome version", "last 1 firefox version", "last 1 safari version"]
  }
}
EOF

# Create necessary directories
mkdir -p src/components src/components/ui src/lib src/hooks src/constants src/types

# src/components/ErrorBoundary.tsx
print_status "Creating src/components/ErrorBoundary.tsx..."
cat > src/components/ErrorBoundary.tsx <<'EOF'
import React from 'react';

interface ErrorBoundaryProps {
  children: React.ReactNode;
}

interface ErrorBoundaryState {
  hasError: boolean;
}

export class ErrorBoundary extends React.Component<
  ErrorBoundaryProps,
  ErrorBoundaryState
> {
  constructor(props: ErrorBoundaryProps) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(_: Error): ErrorBoundaryState {
    // Update state so the next render shows the fallback UI.
    return { hasError: true };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    // You can log the error to an error reporting service here
    console.error('Uncaught error:', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="p-6 text-center">
          <h2 className="text-2xl font-semibold mb-4">
            Something went wrong.
          </h2>
          <p className="text-gray-600">
            An unexpected error occurred. Please try refreshing the page.
          </p>
        </div>
      );
    }

    return this.props.children;
  }
}
EOF

# src/components/ui/card.tsx
print_status "Creating src/components/ui/card.tsx..."
cat > src/components/ui/card.tsx <<'EOF'
import * as React from 'react';
import { cn } from '../../lib/utils';

export interface CardProps
  extends React.HTMLAttributes<HTMLDivElement> {}

export const Card = React.forwardRef<HTMLDivElement, CardProps>(
  ({ className, ...props }, ref) => (
    <div
      ref={ref}
      className={cn(
        'rounded-lg border bg-card text-card-foreground shadow-sm',
        className
      )}
      {...props}
    />
  )
);
Card.displayName = 'Card';

export interface CardHeaderProps
  extends React.HTMLAttributes<HTMLDivElement> {}

export const CardHeader = React.forwardRef<
  HTMLDivElement,
  CardHeaderProps
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn('flex flex-col space-y-1.5 p-6', className)}
    {...props}
  />
));
CardHeader.displayName = 'CardHeader';

export interface CardTitleProps
  extends React.HTMLAttributes<HTMLHeadingElement> {}

export const CardTitle = React.forwardRef<
  HTMLHeadingElement,
  CardTitleProps
>(({ className, ...props }, ref) => (
  <h3
    ref={ref}
    className={cn(
      'text-lg font-semibold leading-none tracking-tight',
      className
    )}
    {...props}
  />
));
CardTitle.displayName = 'CardTitle';

export interface CardContentProps
  extends React.HTMLAttributes<HTMLDivElement> {}

export const CardContent = React.forwardRef<
  HTMLDivElement,
  CardContentProps
>(({ className, ...props }, ref) => (
  <div ref={ref} className={cn('p-6 pt-0', className)} {...props} />
));
CardContent.displayName = 'CardContent';
EOF

# src/components/ui/alert.tsx
print_status "Creating src/components/ui/alert.tsx..."
cat > src/components/ui/alert.tsx <<'EOF'
import * as React from 'react';
import { cn } from '../../lib/utils';

export interface AlertProps
  extends React.HTMLAttributes<HTMLDivElement> {
  variant?: 'default' | 'destructive';
}

const alertVariants = {
  default: 'bg-background text-foreground',
  destructive:
    'text-destructive border-destructive/50 dark:border-destructive [&>svg]:text-destructive text-destructive',
};

export const Alert = React.forwardRef<HTMLDivElement, AlertProps>(
  ({ className, variant = 'default', ...props }, ref) => (
    <div
      ref={ref}
      role="alert"
      className={cn(
        'relative w-full rounded-lg border p-4',
        alertVariants[variant],
        className
      )}
      {...props}
    />
  )
);
Alert.displayName = 'Alert';

export interface AlertDescriptionProps
  extends React.HTMLAttributes<HTMLParagraphElement> {}

export const AlertDescription = React.forwardRef<
  HTMLParagraphElement,
  AlertDescriptionProps
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn('text-sm [&_p]:leading-relaxed', className)}
    {...props}
  />
));
AlertDescription.displayName = 'AlertDescription';
EOF

# src/components/PhaseNavigation.tsx
print_status "Creating src/components/PhaseNavigation.tsx..."
cat > src/components/PhaseNavigation.tsx <<'EOF'
import React from 'react';
import { PhaseKey, Phases } from '../types';
import { cn } from '../lib/utils';

interface PhaseNavigationProps {
  phases: Phases;
  activePhase: PhaseKey;
  onPhaseChange: (phase: PhaseKey) => void;
}

export const PhaseNavigation: React.FC<PhaseNavigationProps> = ({
  phases,
  activePhase,
  onPhaseChange,
}) => {
  return (
    <div className="flex flex-wrap md:flex-nowrap gap-2 bg-gray-100 p-2 rounded-lg">
      {Object.entries(phases).map(([key, phase]) => (
        <button
          key={key}
          onClick={() => onPhaseChange(key as PhaseKey)}
          className={cn(
            'flex-1 px-4 py-2 rounded-md transition-colors',
            activePhase === key
              ? 'bg-white shadow text-blue-600'
              : 'hover:bg-white/50'
          )}
          aria-current={activePhase === key ? 'page' : undefined}
        >
          {phase.title}
        </button>
      ))}
    </div>
  );
};
EOF

# src/components/QuestionItem.tsx
print_status "Creating src/components/QuestionItem.tsx..."
cat > src/components/QuestionItem.tsx <<'EOF'
import React from 'react';
import { Circle, CheckCircle2 } from 'lucide-react';
import { cn } from '../lib/utils';

interface QuestionItemProps {
  question: string;
  isCompleted: boolean;
  onToggle: () => void;
}

export const QuestionItem: React.FC<QuestionItemProps> = ({
  question,
  isCompleted,
  onToggle,
}) => {
  return (
    <li
      className="flex items-start gap-3 cursor-pointer group"
      onClick={onToggle}
      role="checkbox"
      aria-checked={isCompleted}
      tabIndex={0}
      onKeyPress={(e) => {
        if (e.key === 'Enter' || e.key === ' ') {
          onToggle();
        }
      }}
    >
      {isCompleted ? (
        <CheckCircle2 className="w-5 h-5 text-green-500 mt-0.5 flex-shrink-0" />
      ) : (
        <Circle className="w-5 h-5 text-gray-300 group-hover:text-gray-400 mt-0.5 flex-shrink-0" />
      )}
      <span
        className={cn(
          'transition-colors',
          isCompleted && 'text-gray-500 line-through'
        )}
      >
        {question}
      </span>
    </li>
  );
};
EOF

# src/components/TipsList.tsx
print_status "Creating src/components/TipsList.tsx..."
cat > src/components/TipsList.tsx <<'EOF'
import React from 'react';

interface TipsListProps {
  tips: string[];
}

export const TipsList: React.FC<TipsListProps> = ({ tips }) => {
  return (
    <ul className="space-y-2">
      {tips.map((tip, idx) => (
        <li key={idx} className="flex items-center gap-2 text-sm">
          <span className="w-5 h-5 rounded-full bg-blue-100 text-blue-500 flex items-center justify-center flex-shrink-0">
            {idx + 1}
          </span>
          <span>{tip}</span>
        </li>
      ))}
    </ul>
  );
};
EOF

# src/lib/utils.ts
print_status "Creating src/lib/utils.ts..."
cat > src/lib/utils.ts <<'EOF'
import { clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: any[]) {
  return twMerge(clsx(inputs));
}
EOF

# src/hooks/useTimer.ts
print_status "Creating src/hooks/useTimer.ts..."
cat > src/hooks/useTimer.ts <<'EOF'
import { useState, useEffect, useCallback } from 'react';

interface UseTimer {
  timer: number;
  isRunning: boolean;
  startTimer: () => void;
  pauseTimer: () => void;
  resetTimer: () => void;
  formatTime: (seconds: number) => string;
}

export const useTimer = (initialTime: number = 3600): UseTimer => {
  const [timer, setTimer] = useState<number>(initialTime);
  const [isRunning, setIsRunning] = useState<boolean>(false);

  useEffect(() => {
    let interval: NodeJS.Timeout;
    if (isRunning && timer > 0) {
      interval = setInterval(() => {
        setTimer((prev) => prev - 1);
      }, 1000);
    }
    return () => {
      if (interval) clearInterval(interval);
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
    return `${mins.toString().padStart(2, '0')}:${secs
      .toString()
      .padStart(2, '0')}`;
  }, []);

  return {
    timer,
    isRunning,
    startTimer,
    pauseTimer,
    resetTimer,
    formatTime,
  };
};
EOF

# src/hooks/usePhases.ts
print_status "Creating src/hooks/usePhases.ts..."
cat > src/hooks/usePhases.ts <<'EOF'
import { useState, useCallback } from 'react';
import { PHASES_DATA } from '../constants';
import { PhaseKey, Phases, CompletedTasks, Notes } from '../types';

interface UsePhases {
  phases: Phases;
  activePhase: PhaseKey;
  setActivePhase: (phase: PhaseKey) => void;
  completedTasks: CompletedTasks;
  toggleTaskCompletion: (phaseKey: PhaseKey, questionIdx: number) => void;
  notes: Notes;
  handleNotesChange: (phase: PhaseKey, value: string) => void;
}

export const usePhases = (): UsePhases => {
  const [activePhase, setActivePhase] = useState<PhaseKey>('connect');
  const [completedTasks, setCompletedTasks] = useState<CompletedTasks>({});
  const [notes, setNotes] = useState<Notes>(() =>
    Object.keys(PHASES_DATA).reduce(
      (acc, key) => ({ ...acc, [key]: '' }),
      {} as Notes
    )
  );

  const toggleTaskCompletion = useCallback(
    (phaseKey: PhaseKey, questionIdx: number) => {
      setCompletedTasks((prev) => ({
        ...prev,
        [`${phaseKey}-${questionIdx}`]: !prev[`${phaseKey}-${questionIdx}`],
      }));
    },
    []
  );

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

# src/constants/index.ts
print_status "Creating src/constants/index.ts..."
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

export const INITIAL_TIMER = 3600; // 1 hour in seconds
EOF

# src/types/index.ts
print_status "Creating src/types/index.ts..."
cat > src/types/index.ts <<'EOF'
export type PhaseKey =
  | 'connect'
  | 'explore'
  | 'structure'
  | 'document'
  | 'grow';

export interface Phase {
  title: string;
  duration: string;
  questions: string[];
  tips: string[];
}

export interface Phases {
  [key: string]: Phase;
}

export interface CompletedTasks {
  [key: string]: boolean;
}

export interface Notes {
  [key: string]: string;
}
EOF


# Final success message
print_success "Setup complete! You can now run 'npm start' in the project directory to start the application."
print_status "Navigate to $PROJECT_DIR and run 'npm start' to begin."
