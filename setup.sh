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
