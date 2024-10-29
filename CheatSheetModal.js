// src/components/CheatSheetModal.js
import React from 'react';
import { X } from 'lucide-react';

export default function CheatSheetModal({ phase, onClose }) {
  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-lg shadow-lg max-w-md w-full p-6 relative">
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
