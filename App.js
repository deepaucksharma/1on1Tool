// src/App.js
import React, { useState, useEffect } from 'react';
import {
  Clock,
  AlertCircle,
  CheckCircle,
  PlusCircle,
  ChevronRight,
  FileText,
} from 'lucide-react';
import RichTextEditor from './components/RichTextEditor';
import TagInput from './components/TagInput';
import CheatSheetModal from './components/CheatSheetModal';
import './index.css'; // Import Tailwind CSS styles

// Default phases aligned with the Cheat Sheet
const defaultPhases = {
  connect: {
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
      {
        text: 'I experienced something similar recently...',
        categories: ['Relationship'],
      },
    ],
    tips: [
      'Start with a personal check-in to build rapport',
      'Practice active listening',
      'Share brief personal anecdotes',
    ],
    redFlags: [],
  },
  explore: {
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
        text: 'What are you most excited about in your current project?',
        categories: ['Performance', 'Growth'],
      },
      {
        text: 'How can I best support you?',
        categories: ['Support', 'Relationship'],
      },
    ],
    tips: ['Use open-ended questions', 'Identify challenges early', 'Offer concrete support'],
    redFlags: ['Signs of disengagement or burnout', 'Lack of progress on key tasks'],
  },
  structure: {
    id: 'structure',
    title: 'Structure',
    duration: '5-10 min',
    purpose: 'Optimize time and ensure productive discussions',
    principle: 'Optimize Time',
    essentialActions: ['Set a clear agenda', 'Prioritize topics', 'Timebox discussions'],
    questions: [
      {
        text: 'What are the most important things we need to discuss today?',
        categories: ['Clarity', 'Performance'],
      },
      {
        text: "Let's aim to spend 15 minutes on this topic.",
        categories: ['Clarity', 'Time Management'],
      },
      {
        text: 'Is there anything else we need to cover before we wrap up?',
        categories: ['Clarity'],
      },
    ],
    tips: ['Ensure clear expectations and ownership for action items'],
    redFlags: ['Lack of clarity on priorities', 'Too many unfocused topics'],
  },
  document: {
    id: 'document',
    title: 'Document',
    duration: '5-10 min',
    purpose: 'Ensure clarity and accountability',
    principle: 'Ensure Clarity',
    essentialActions: ['Capture key decisions', 'Assign action items', 'Share notes'],
    questions: [
      {
        text: "Let's make sure we capture that decision.",
        categories: ['Accountability', 'Clarity'],
      },
      {
        text: 'Can you take ownership of that action item?',
        categories: ['Accountability'],
      },
      {
        text: "What's a realistic deadline for completing this?",
        categories: ['Accountability', 'Time Management'],
      },
    ],
    tips: ['Don’t forget to capture any agreed-upon changes to project scope'],
    redFlags: ['Unclear ownership of tasks', 'Missing deadlines for action items'],
  },
  grow: {
    id: 'grow',
    title: 'Grow',
    duration: '10-15 min',
    purpose: 'Facilitate development and growth opportunities',
    principle: 'Facilitate Development',
    essentialActions: ['Discuss aspirations', 'Provide feedback', 'Identify resources'],
    questions: [
      {
        text: 'What are your long-term career goals?',
        categories: ['Growth'],
      },
      {
        text: "I've noticed you're excelling in this area. How can we build on that?",
        categories: ['Growth', 'Performance'],
      },
      {
        text: 'Have you considered this course to help develop that skill?',
        categories: ['Growth', 'Resources'],
      },
    ],
    tips: ['Encourage continuous learning and provide opportunities for skill development'],
    redFlags: ['Lack of growth mindset', 'No progress on development goals'],
  },
};

// All available categories
const allCategories = [
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

function App() {
  const [phases, setPhases] = useState(() => {
    try {
      const savedPhases = localStorage.getItem('phases');
      return savedPhases ? JSON.parse(savedPhases) : defaultPhases;
    } catch (error) {
      console.error("Error loading phases from localStorage:", error);
      return defaultPhases;
    }
  });
  const [activePhase, setActivePhase] = useState('connect');
  const [notes, setNotes] = useState(() => {
    try {
      return localStorage.getItem('notes') || '';
    } catch (error) {
      console.error("Error loading notes from localStorage:", error);
      return '';
    }
  });
  const [noteCategories, setNoteCategories] = useState(() => {
    try {
      const savedCategories = localStorage.getItem('noteCategories');
      return savedCategories ? JSON.parse(savedCategories) : [];
    } catch (error) {
      console.error("Error loading note categories from localStorage:", error);
      return [];
    }
  });
  const [showCheatSheet, setShowCheatSheet] = useState(false);
  const [actionItems, setActionItems] = useState(() => {
    try {
      const savedItems = localStorage.getItem('actionItems');
      return savedItems ? JSON.parse(savedItems) : [];
    } catch (error) {
      console.error("Error loading action items from localStorage:", error);
      return [];
    }
  });
  const [selectedCategories, setSelectedCategories] = useState([]);

  useEffect(() => {
    try {
      localStorage.setItem('phases', JSON.stringify(phases));
    } catch (error) {
      console.error("Error saving phases to localStorage:", error);
    }
  }, [phases]);

  useEffect(() => {
    try {
      localStorage.setItem('notes', notes);
    } catch (error) {
      console.error("Error saving notes to localStorage:", error);
    }
  }, [notes]);

  useEffect(() => {
    try {
      localStorage.setItem('noteCategories', JSON.stringify(noteCategories));
    } catch (error) {
      console.error("Error saving note categories to localStorage:", error);
    }
  }, [noteCategories]);

  useEffect(() => {
    try {
      localStorage.setItem('actionItems', JSON.stringify(actionItems));
    } catch (error) {
      console.error("Error saving action items to localStorage:", error);
    }
  }, [actionItems]);

  const addActionItem = () => {
    setActionItems([
      ...actionItems,
      { text: '', owner: '', deadline: '', status: 'pending' },
    ]);
  };

  const updateActionItem = (index, field, value) => {
    const updatedItems = [...actionItems];
    if (field === 'deadline') {
      if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) {
        alert("Invalid date format. Please use YYYY-MM-DD.");
        return;
      }
    }
    updatedItems[index][field] = value;
    setActionItems(updatedItems);
  };

  const deleteActionItem = (index) => {
    setActionItems(actionItems.filter((_, i) => i !== index));
  };

  const toggleCategory = (category) => {
    setSelectedCategories(
      selectedCategories.includes(category)
        ? selectedCategories.filter((c) => c !== category)
        : [...selectedCategories, category]
    );
  };

  const filterContentByCategories = (content) => {
    if (selectedCategories.length === 0) return content;
    return content.filter((item) =>
      item.categories.some((category) => selectedCategories.includes(category))
    );
  };

  return (
    <div className="max-w-6xl mx-auto p-6">
      <div className="bg-white rounded-lg shadow">
        <div className="flex flex-row items-center justify-between p-6 border-b">
          <div>
            <h1 className="text-2xl font-bold">1-on-1 Meeting Tool</h1>
            <p className="text-sm text-gray-500 mt-1">
              {phases[activePhase].purpose}
            </p>
          </div>
          <div className="flex items-center gap-4">
            <button
              onClick={() => setShowCheatSheet(!showCheatSheet)}
              className="flex items-center gap-1 text-sm text-blue-500"
            >
              <FileText className="w-4 h-4" />
              {showCheatSheet ? 'Hide' : 'Show'} Cheat Sheet
            </button>
            <div className="flex items-center gap-2">
              <Clock className="w-5 h-5" />
              <span className="text-sm font-medium">
                {phases[activePhase].duration}
              </span>
            </div>
          </div>
        </div>

        <div className="grid grid-cols-12 gap-6 p-6">
          {/* Main Content (8 cols) */}
          <div className="col-span-8">
            {/* Phase Navigation */}
            <div className="flex gap-2 mb-6 overflow-x-auto pb-2">
              {Object.entries(phases).map(([key, phase]) => (
                <button
                  key={key}
                  onClick={() => setActivePhase(key)}
                  className={`px-4 py-2 rounded-lg flex items-center gap-2 whitespace-nowrap ${
                    activePhase === key
                      ? 'bg-blue-500 text-white'
                      : 'bg-gray-100 hover:bg-gray-200'
                  }`}
                >
                  {phase.title}
                  <span className="text-xs opacity-75">({phase.duration})</span>
                </button>
              ))}
              {/* Option to add new phases */}
              <button
                onClick={() => {
                  // Logic to add a new phase
                  const newPhaseId = `phase_${Date.now()}`;
                  setPhases({
                    ...phases,
                    [newPhaseId]: {
                      id: newPhaseId,
                      title: 'New Phase',
                      duration: '10 min',
                      purpose: '',
                      principle: '',
                      essentialActions: [],
                      questions: [],
                      tips: [],
                      redFlags: [],
                    },
                  });
                  setActivePhase(newPhaseId);
                }}
                className="flex items-center gap-1 px-4 py-2 text-sm text-green-500"
              >
                <PlusCircle className="w-4 h-4" />
                Add Phase
              </button>
            </div>

            {/* Phase Content */}
            <div className="space-y-6">
              {/* Cheat Sheet Integration */}
              {showCheatSheet && (
                <CheatSheetModal
                  phase={phases[activePhase]}
                  onClose={() => setShowCheatSheet(false)}
                />
              )}

              {/* Principle and Essential Actions */}
              <section>
                <h3 className="text-lg font-semibold mb-4">Phase Overview</h3>
                <div className="bg-white rounded-lg p-4 shadow-sm border">
                  <p className="text-sm">
                    <strong>Principle:</strong> {phases[activePhase].principle}
                  </p>
                  <p className="text-sm mt-2">
                    <strong>Essential Actions:</strong>
                  </p>
                  <ul className="list-disc list-inside text-sm mt-1">
                    {phases[activePhase].essentialActions.map((action, i) => (
                      <li key={i}>{action}</li>
                    ))}
                  </ul>
                </div>
              </section>

              {/* Questions Section */}
              <section>
                <h3 className="text-lg font-semibold mb-4">Key Questions</h3>
                <ul className="space-y-4">
                  {filterContentByCategories(phases[activePhase].questions).map(
                    (q, i) => (
                      <li
                        key={i}
                        className="bg-white rounded-lg p-4 shadow-sm border"
                      >
                        <div className="flex items-start gap-3">
                          <span className="w-6 h-6 rounded-full bg-blue-100 text-blue-500 flex items-center justify-center flex-shrink-0">
                            {i + 1}
                          </span>
                          <div className="flex-1">
                            <p className="font-medium mb-2">{q.text}</p>
                            <div className="flex flex-wrap gap-2">
                              {q.categories.map((cat) => (
                                <span
                                  key={cat}
                                  className="px-2 py-1 bg-blue-50 text-blue-600 rounded-full text-xs"
                                >
                                  {cat}
                                </span>
                              ))}
                            </div>
                          </div>
                        </div>
                      </li>
                    )
                  )}
                </ul>
              </section>

              {/* Notes Section with Rich Text Editor */}
              <section>
                <h3 className="text-lg font-semibold mb-4">Notes</h3>
                <div className="bg-white rounded-lg p-4 shadow-sm border">
                  <RichTextEditor
                    content={notes}
                    onChange={(content) => setNotes(content)}
                  />
                  <div className="flex flex-wrap gap-2 mt-3">
                    <TagInput
                      availableTags={allCategories}
                      selectedTags={noteCategories}
                      onChange={(tags) => setNoteCategories(tags)}
                    />
                  </div>
                </div>
              </section>

              {/* Action Items */}
              <section>
                <div className="flex items-center justify-between mb-4">
                  <h3 className="text-lg font-semibold">Action Items</h3>
                  <button
                    onClick={addActionItem}
                    className="flex items-center gap-1 text-sm text-blue-500"
                  >
                    <PlusCircle className="w-4 h-4" />
                    Add Item
                  </button>
                </div>
                <ul className="space-y-3">
                  {actionItems.map((item, i) => (
                    <li
                      key={i}
                      className="bg-white rounded-lg p-4 shadow-sm border"
                    >
                      <div className="grid grid-cols-12 gap-4">
                        <input
                          className="col-span-6 p-2 border rounded"
                          value={item.text}
                          onChange={(e) =>
                            updateActionItem(i, 'text', e.target.value)
                          }
                          placeholder="Action item description"
                        />
                        <input
                          className="col-span-2 p-2 border rounded"
                          value={item.owner}
                          onChange={(e) =>
                            updateActionItem(i, 'owner', e.target.value)
                          }
                          placeholder="Owner"
                        />
                        <input
                          type="date"
                          className="col-span-2 p-2 border rounded"
                          value={item.deadline}
                          onChange={(e) =>
                            updateActionItem(i, 'deadline', e.target.value)
                          }
                        />
                        <select
                          className="col-span-2 p-2 border rounded"
                          value={item.status}
                          onChange={(e) =>
                            updateActionItem(i, 'status', e.target.value)
                          }
                        >
                          <option value="pending">Pending</option>
                          <option value="in-progress">In Progress</option>
                          <option value="completed">Completed</option>
                        </select>
                        <button onClick={() => deleteActionItem(i)} className="text-red-500 hover:text-red-700">
                          Delete
                        </button>
                      </div>
                    </li>
                  ))}
                </ul>
              </section>
            </div>
          </div>

          {/* Sidebar (4 cols) */}
          <div className="col-span-4 space-y-6">
            {/* Categories Filter */}
            <div className="bg-white rounded-lg p-4 shadow">
              <h2 className="text-base font-semibold mb-4">Filter by Category</h2>
              <div className="flex flex-wrap gap-2">
                {allCategories.map((cat) => (
                  <button
                    key={cat}
                    onClick={() => toggleCategory(cat)}
                    className={`px-3 py-1 rounded-full text-sm ${
                      selectedCategories.includes(cat)
                        ? 'bg-blue-500 text-white'
                        : 'bg-gray-100 hover:bg-gray-200'
                    }`}
                  >
                    {cat}
                  </button>
                ))}
              </div>
            </div>

            {/* Tips and Red Flags */}
            <div className="space-y-4">
              {phases[activePhase].tips.length > 0 && (
                <div className="bg-green-50 border-l-4 border-green-400 p-4">
                  <div className="flex">
                    <CheckCircle className="w-5 h-5 text-green-600 mt-1" />
                    <div className="ml-3">
                      <h4 className="text-lg font-medium text-green-800 mb-2">Tips</h4>
                      <ul className="text-sm text-green-700 space-y-1">
                        {phases[activePhase].tips.map((tip, i) => (
                          <li key={i} className="flex items-start gap-2">
                            <ChevronRight className="w-4 h-4 flex-shrink-0" />
                            {tip}
                          </li>
                        ))}
                      </ul>
                    </div>
                  </div>
                </div>
              )}

              {phases[activePhase].redFlags.length > 0 && (
                <div className="bg-red-50 border-l-4 border-red-400 p-4">
                  <div className="flex">
                    <AlertCircle className="w-5 h-5 text-red-600 mt-1" />
                    <div className="ml-3">
                      <h4 className="text-lg font-medium text-red-800 mb-2">
                        Red Flags
                      </h4>
                      <ul className="text-sm text-red-700 space-y-1">
                        {phases[activePhase].redFlags.map((flag, i) => (
                          <li key={i} className="flex items-start gap-2">
                            <ChevronRight className="w-4 h-4 flex-shrink-0" />
                            {flag}
                          </li>
                        ))}
                      </ul>
                    </div>
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default App;
