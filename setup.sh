#!/bin/bash

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
        exit 1
    fi
}

# Function to check Node.js version
check_node_version() {
    local min_version="14.0.0"
    local max_version="18.0.0"
    local current_version=$(node -v | cut -d 'v' -f 2)

    if [[ "$(printf '%s\n' "$min_version" "$current_version" | sort -V | head -n1)" != "$min_version" ]] || \
       [[ "$(printf '%s\n' "$max_version" "$current_version" | sort -V | tail -n1)" != "$max_version" ]]; then
        print_error "Node.js version must be >= $min_version and < $max_version. Current version: $current_version"
        exit 1
    fi
}

# Check if Node.js and npm are installed
check_command node
check_node_version
check_command npm

# Check for existing npm processes
if lsof -i tcp:3000 | grep LISTEN; then
    print_error "Port 3000 is already in use. Please close any running applications on this port."
    exit 1
fi

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
    @shadcn/ui \
    clsx \
    lucide-react \
    tailwind-merge \
    tailwindcss@latest \
    @tailwindcss/forms \
    @tailwindcss/typography \
    react@18.2.0 \
    react-dom@18.2.0 || {
        print_error "Failed to install dependencies"
        exit 1
    }

# Install dev dependencies
print_status "Installing dev dependencies..."
npm install --save-dev \
    @types/node@18.17.1 \
    @types/react@18.2.18 \
    @types/react-dom@18.2.7 \
    autoprefixer \
    postcss \
    typescript \
    eslint \
    eslint-config-react-app \
    eslint-plugin-react-hooks \
    prettier \
    eslint-config-prettier \
    eslint-plugin-prettier || {
        print_error "Failed to install dev dependencies"
        exit 1
    }

# Initialize Tailwind CSS
print_status "Setting up Tailwind CSS..."
npx tailwindcss init -p

# Update Tailwind config
print_status "Configuring Tailwind CSS..."
cat > tailwind.config.js <<'EOF'
/** @type {import('tailwindcss').Config} */
const { fontFamily } = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './src/**/*.{js,jsx,ts,tsx}',
    './node_modules/@shadcn/ui/**/*.js',
  ],
  darkMode: 'class',
  theme: {
    extend: {
      fontFamily: {
        sans: ['var(--font-sans)', ...fontFamily.sans],
      },
      colors: {
        border: 'hsl(var(--border) / <alpha-value>)',
        input: 'hsl(var(--input) / <alpha-value>)',
        ring: 'hsl(var(--ring) / <alpha-value>)',
        background: 'hsl(var(--background) / <alpha-value>)',
        foreground: 'hsl(var(--foreground) / <alpha-value>)',
        primary: {
          DEFAULT: 'hsl(var(--primary) / <alpha-value>)',
          foreground: 'hsl(var(--primary-foreground) / <alpha-value>)',
        },
        destructive: {
          DEFAULT: 'hsl(var(--destructive) / <alpha-value>)',
          foreground: 'hsl(var(--destructive-foreground) / <alpha-value>)',
        },
        muted: {
          DEFAULT: 'hsl(var(--muted) / <alpha-value>)',
          foreground: 'hsl(var(--muted-foreground) / <alpha-value>)',
        },
        accent: {
          DEFAULT: 'hsl(var(--accent) / <alpha-value>)',
          foreground: 'hsl(var(--accent-foreground) / <alpha-value>)',
        },
        popover: {
          DEFAULT: 'hsl(var(--popover) / <alpha-value>)',
          foreground: 'hsl(var(--popover-foreground) / <alpha-value>)',
        },
        card: {
          DEFAULT: 'hsl(var(--card) / <alpha-value>)',
          foreground: 'hsl(var(--card-foreground) / <alpha-value>)',
        },
      },
      borderRadius: {
        lg: 'var(--radius)',
        md: 'calc(var(--radius) - 2px)',
        sm: 'calc(var(--radius) - 4px)',
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@shadcn/ui/plugins'),
  ],
}
EOF

# Create src/index.css with complete CSS variables
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

    --border: 214.3 31.8% 91.4%;
    --input: 214.3 31.8% 91.4%;

    --primary: 222.2 47.4% 11.2%;
    --primary-foreground: 210 40% 98%;

    --destructive: 0 84.2% 60.2%;
    --destructive-foreground: 210 40% 98%;

    --muted: 210 40% 96.1%;
    --muted-foreground: 215.4 16.3% 46.9%;

    --accent: 210 40% 96.1%;
    --accent-foreground: 222.2 47.4% 11.2%;

    --ring: 215 20.2% 65.1%;

    --radius: 0.5rem;
  }

  .dark {
    --background: 222.2 84% 4.9%;
    --foreground: 210 40% 98%;

    --card: 222.2 84% 4.9%;
    --card-foreground: 210 40% 98%;

    --popover: 222.2 84% 4.9%;
    --popover-foreground: 210 40% 98%;

    --border: 217.2 32.6% 17.5%;
    --input: 217.2 32.6% 17.5%;

    --primary: 210 40% 98%;
    --primary-foreground: 222.2 47.4% 11.2%;

    --destructive: 0 62.8% 30.6%;
    --destructive-foreground: 210 40% 98%;

    --muted: 217.2 32.6% 17.5%;
    --muted-foreground: 215 20.2% 65.1%;

    --accent: 217.2 32.6% 17.5%;
    --accent-foreground: 210 40% 98%;

    --ring: 212.7 26.8% 83.9%;
  }

  body {
    @apply bg-background text-foreground;
  }
}
EOF

# Update src/index.tsx with ErrorBoundary
print_status "Updating index.tsx..."
cat > src/index.tsx <<'EOF'
import React from 'react';
import { createRoot } from 'react-dom/client';
import './index.css';
import App from './App';
import { ErrorBoundary } from './components/ErrorBoundary';

const container = document.getElementById('root');
if (!container) throw new Error('Failed to find the root element');
const root = createRoot(container);

root.render(
  <React.StrictMode>
    <ErrorBoundary>
      <App />
    </ErrorBoundary>
  </React.StrictMode>
);
EOF

# Remove default files
rm -f src/App.css src/App.test.tsx src/logo.svg src/reportWebVitals.ts src/setupTests.ts

# Create necessary directories
mkdir -p src/components/ui src/lib src/hooks src/constants src/types src/components

# Create .eslintrc.js
print_status "Creating ESLint configuration..."
cat > .eslintrc.js <<'EOF'
module.exports = {
  extends: ['react-app', 'react-app/jest', 'plugin:react-hooks/recommended', 'prettier'],
  plugins: ['react-hooks', 'prettier'],
  rules: {
    'prettier/prettier': 'error',
  },
};
EOF

# Create .prettierrc
print_status "Creating Prettier configuration..."
cat > .prettierrc <<'EOF'
{
  "semi": true,
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2,
  "trailingComma": "es5"
}
EOF

# Update tsconfig.json with strict mode and paths
print_status "Updating tsconfig.json..."
cat > tsconfig.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["DOM", "DOM.Iterable", "ES2020"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "ESNext",
    "moduleResolution": "Node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "react-jsx",
    "baseUrl": "src",
    "paths": {
      "@components/*": ["components/*"],
      "@hooks/*": ["hooks/*"],
      "@constants/*": ["constants/*"],
      "@types/*": ["types/*"],
      "@lib/*": ["lib/*"]
    }
  },
  "include": ["src"]
}
EOF

# Create .env file
print_status "Creating .env file..."
cat > .env <<'EOF'
# You can set custom environment variables here
EOF

# Create src/global.d.ts for global types
print_status "Creating global types declaration..."
cat > src/global.d.ts <<'EOF'
// Add any global type declarations here
EOF


# Create src/App.tsx with the full content
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

const App: React.FC = () => {
  const {
    timer,
    isRunning: isTimerRunning,
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

  // Compute completion percentage
  const completionPercentage = useMemo(() => {
    const total = Object.keys(phases).reduce(
      (acc, phase) => acc + phases[phase as PhaseKey].questions.length,
      0
    );
    const completed = Object.values(completedTasks).filter(Boolean).length;
    return Math.round((completed / total) * 100);
  }, [phases, completedTasks]);

  return (
    <div className="max-w-6xl mx-auto p-6 space-y-6">
      {/* Timer and Progress Section */}
      <div className="flex flex-col md:flex-row gap-4 items-start md:items-center justify-between">
        <div className="flex items-center gap-4">
          <div className="flex items-center gap-2">
            <Clock className="w-5 h-5" />
            <span className="font-mono text-xl">{formatTime(timer)}</span>
          </div>
          <div className="space-x-2">
            {!isTimerRunning ? (
              <button
                onClick={startTimer}
                className="px-3 py-1 bg-blue-500 text-white rounded-md hover:bg-blue-600"
              >
                Start
              </button>
            ) : (
              <button
                onClick={pauseTimer}
                className="px-3 py-1 bg-yellow-500 text-white rounded-md hover:bg-yellow-600"
              >
                Pause
              </button>
            )}
            <button
              onClick={resetTimer}
              className="px-3 py-1 bg-gray-500 text-white rounded-md hover:bg-gray-600"
            >
              Reset
            </button>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <span>Progress: {completionPercentage}%</span>
          <div className="w-32 h-2 bg-gray-200 rounded-full">
            <div
              className="h-full bg-blue-500 rounded-full"
              style={{ width: `${completionPercentage}%` }}
            />
          </div>
        </div>
      </div>

      {/* Phase Navigation */}
      <PhaseNavigation
        phases={phases}
        activePhase={activePhase}
        onPhaseChange={setActivePhase}
      />

      {/* Main Content */}
      <div className="grid md:grid-cols-2 gap-6">
        {/* Questions Section */}
        <Card>
          <CardHeader>
            <CardTitle>
              {currentPhase.title} ({currentPhase.duration})
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <ul className="space-y-3">
              {currentPhase.questions.map((question, idx) => (
                <QuestionItem
                  key={idx}
                  question={question}
                  isCompleted={!!completedTasks[`${activePhase}-${idx}`]}
                  onToggle={() => toggleTaskCompletion(activePhase, idx)}
                />
              ))}
            </ul>
            <textarea
              value={notes[activePhase]}
              onChange={(e) => handleNotesChange(activePhase, e.target.value)}
              placeholder="Add notes..."
              className="w-full mt-4 p-2 border rounded-md min-h-[100px]"
            />
          </CardContent>
        </Card>

        {/* Tips and Warnings Section */}
        <div className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle>Tips</CardTitle>
            </CardHeader>
            <CardContent>
              <TipsList tips={currentPhase.tips} />
            </CardContent>
          </Card>

          <Alert variant="destructive">
            <AlertCircle className="w-4 h-4" />
            <AlertDescription className="mt-2">
              <h4 className="font-semibold mb-2">Red Flags to Watch For:</h4>
              <ul className="list-disc pl-4 space-y-1">
                {RED_FLAGS.map((flag, idx) => (
                  <li key={idx}>{flag}</li>
                ))}
              </ul>
            </AlertDescription>
          </Alert>
        </div>
      </div>
    </div>
  );
};

export default App;
EOF


# Create src/components/ErrorBoundary.tsx
print_status "Creating src/components/ErrorBoundary.tsx..."
cat > src/components/ErrorBoundary.tsx <<'EOF'
import React from 'react';

interface ErrorBoundaryState {
  hasError: boolean;
  error: Error | null;
}

export class ErrorBoundary extends React.Component<{}, ErrorBoundaryState> {
  constructor(props: {}) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error: Error): ErrorBoundaryState {
    // Update state so the next render shows the fallback UI.
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, info: React.ErrorInfo) {
    // You can log the error to an error reporting service here
    console.error('ErrorBoundary caught an error', error, info);
  }

  render() {
    if (this.state.hasError && this.state.error) {
      // You can render any custom fallback UI
      return (
        <div className="p-6 text-center">
          <h1 className="text-2xl font-bold">Something went wrong.</h1>
          <p className="mt-4 text-gray-600">{this.state.error.message}</p>
        </div>
      );
    }

    return this.props.children;
  }
}
EOF

# Create src/components/ui/card.tsx
print_status "Creating src/components/ui/card.tsx..."
cat > src/components/ui/card.tsx <<'EOF'
import React from 'react';
import { cn } from '../../lib/utils';

interface CardProps extends React.HTMLAttributes<HTMLDivElement> {}

export const Card = React.forwardRef<HTMLDivElement, CardProps>(
  ({ className, ...props }, ref) => (
    <div
      ref={ref}
      className={cn(
        'rounded-lg border bg-white shadow-sm transition-shadow hover:shadow-md',
        className
      )}
      {...props}
    />
  )
);
Card.displayName = 'Card';

interface CardHeaderProps extends React.HTMLAttributes<HTMLDivElement> {}

export const CardHeader = React.forwardRef<HTMLDivElement, CardHeaderProps>(
  ({ className, ...props }, ref) => (
    <div ref={ref} className={cn('flex flex-col space-y-1.5 p-6', className)} {...props} />
  )
);
CardHeader.displayName = 'CardHeader';

interface CardTitleProps extends React.HTMLAttributes<HTMLHeadingElement> {}

export const CardTitle = React.forwardRef<HTMLHeadingElement, CardTitleProps>(
  ({ className, ...props }, ref) => (
    <h3
      ref={ref}
      className={cn('text-lg font-semibold leading-none tracking-tight', className)}
      {...props}
    />
  )
);
CardTitle.displayName = 'CardTitle';

interface CardContentProps extends React.HTMLAttributes<HTMLDivElement> {}

export const CardContent = React.forwardRef<HTMLDivElement, CardContentProps>(
  ({ className, ...props }, ref) => (
    <div ref={ref} className={cn('p-6 pt-0', className)} {...props} />
  )
);
CardContent.displayName = 'CardContent';
EOF

# Create src/components/ui/alert.tsx
print_status "Creating src/components/ui/alert.tsx..."
cat > src/components/ui/alert.tsx <<'EOF'
import React from 'react';
import { cn } from '../../lib/utils';
import { AlertCircle } from 'lucide-react';

interface AlertProps extends React.HTMLAttributes<HTMLDivElement> {
  variant?: 'default' | 'destructive';
}

export const Alert = React.forwardRef<HTMLDivElement, AlertProps>(
  ({ className, variant = 'default', children, ...props }, ref) => (
    <div
      ref={ref}
      role="alert"
      className={cn(
        'relative w-full rounded-lg border p-4 flex items-start space-x-3',
        variant === 'destructive'
          ? 'border-destructive/50 text-destructive bg-destructive/10'
          : 'bg-background text-foreground',
        className
      )}
      {...props}
    >
      {variant === 'destructive' && (
        <AlertCircle className="h-5 w-5 mt-0.5 flex-shrink-0" />
      )}
      <div className="flex-1">{children}</div>
    </div>
  )
);
Alert.displayName = 'Alert';

interface AlertDescriptionProps extends React.HTMLAttributes<HTMLDivElement> {}

export const AlertDescription = React.forwardRef<
  HTMLDivElement,
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

# Create src/components/PhaseNavigation.tsx
print_status "Creating src/components/PhaseNavigation.tsx..."
cat > src/components/PhaseNavigation.tsx <<'EOF'
import React, { memo } from 'react';
import { PhaseKey } from '../types';
import { cn } from '../lib/utils';

interface PhaseNavigationProps {
  phases: Record<PhaseKey, { title: string }>;
  activePhase: PhaseKey;
  onPhaseChange: (phase: PhaseKey) => void;
}

export const PhaseNavigation = memo<PhaseNavigationProps>(
  ({ phases, activePhase, onPhaseChange }) => (
    <div className="flex flex-wrap md:flex-nowrap gap-2 bg-gray-100 p-2 rounded-lg">
      {(Object.entries(phases) as [PhaseKey, { title: string }][]).map(
        ([key, phase]) => (
          <button
            key={key}
            onClick={() => onPhaseChange(key)}
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
        )
      )}
    </div>
  )
);
PhaseNavigation.displayName = 'PhaseNavigation';
EOF

# Create src/components/QuestionItem.tsx
print_status "Creating src/components/QuestionItem.tsx..."
cat > src/components/QuestionItem.tsx <<'EOF'
import React, { memo } from 'react';
import { Circle, CheckCircle2 } from 'lucide-react';
import { cn } from '../lib/utils';

interface QuestionItemProps {
  question: string;
  isCompleted: boolean;
  onToggle: () => void;
}

export const QuestionItem = memo<QuestionItemProps>(
  ({ question, isCompleted, onToggle }) => (
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
        className={cn('transition-colors', isCompleted && 'text-gray-500 line-through')}
      >
        {question}
      </span>
    </li>
  )
);
QuestionItem.displayName = 'QuestionItem';
EOF

# Create src/components/TipsList.tsx
print_status "Creating src/components/TipsList.tsx..."
cat > src/components/TipsList.tsx <<'EOF'
import React, { memo } from 'react';

interface TipsListProps {
  tips: string[];
}

export const TipsList = memo<TipsListProps>(({ tips }) => (
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
));
TipsList.displayName = 'TipsList';
EOF

# Create src/lib/utils.ts
print_status "Creating src/lib/utils.ts..."
cat > src/lib/utils.ts <<'EOF'
import { clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: any[]) {
  return twMerge(clsx(inputs));
}
EOF

# Create src/hooks/useTimer.ts
print_status "Creating src/hooks/useTimer.ts..."
cat > src/hooks/useTimer.ts <<'EOF'
import { useState, useEffect, useCallback } from 'react';
import { UseTimer } from '../types';

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

# Create src/hooks/usePhases.ts
print_status "Creating src/hooks/usePhases.ts..."
cat > src/hooks/usePhases.ts <<'EOF'
import { useState, useCallback } from 'react';
import { PHASES_DATA } from '../constants';
import { UsePhases, PhaseKey, CompletedTasks, Notes } from '../types';

export const usePhases = (): UsePhases => {
  const [activePhase, setActivePhase] = useState<PhaseKey>('connect');

  // Initialize completedTasks with all possible keys
  const [completedTasks, setCompletedTasks] = useState<CompletedTasks>(() => {
    const initialTasks: CompletedTasks = {};
    Object.entries(PHASES_DATA).forEach(([phaseKey, phase]) => {
      phase.questions.forEach((_, questionIdx) => {
        initialTasks[`${phaseKey}-${questionIdx}`] = false;
      });
    });
    return initialTasks;
  });

  const [notes, setNotes] = useState<Notes>(() =>
    Object.keys(PHASES_DATA).reduce((acc, key) => ({ ...acc, [key]: '' }), {})
  );

  const toggleTaskCompletion = useCallback((phaseKey: PhaseKey, questionIdx: number) => {
    setCompletedTasks((prev) => ({
      ...prev,
      [`${phaseKey}-${questionIdx}`]: !prev[`${phaseKey}-${questionIdx}`],
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

# Create src/constants/index.ts
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

# Create src/types/index.ts
print_status "Creating src/types/index.ts..."
cat > src/types/index.ts <<'EOF'
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

export type PhaseKey = 'connect' | 'explore' | 'structure' | 'document' | 'grow';

// Custom hook types
export interface UseTimer {
  timer: number;
  isRunning: boolean;
  startTimer: () => void;
  pauseTimer: () => void;
  resetTimer: () => void;
  formatTime: (seconds: number) => string;
}

export interface UsePhases {
  phases: Phases;
  activePhase: PhaseKey;
  setActivePhase: (phase: PhaseKey) => void;
  completedTasks: CompletedTasks;
  toggleTaskCompletion: (phaseKey: PhaseKey, questionIdx: number) => void;
  notes: Notes;
  handleNotesChange: (phase: PhaseKey, value: string) => void;
}
EOF
# Final success message
print_success "Setup complete! You can now run 'npm start' in the project directory to start the application."
print_status "Navigate to $PROJECT_DIR and run 'npm start' to begin."
