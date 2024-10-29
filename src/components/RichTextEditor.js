// src/components/RichTextEditor.js
import React, { useState } from 'react';
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
  const [editorState, setEditorState] = useState(() => {
    try {
      if (content) {
        const blocksFromHTML = convertFromHTML(content);
        return EditorState.createWithContent(
          ContentState.createFromBlockArray(blocksFromHTML)
        );
      }
    } catch (e) {
      console.error("Error converting HTML:", e);
    }
    return EditorState.createEmpty();
  });

  const handleEditorChange = (state) => {
    setEditorState(state);
    const rawContentState = convertToRaw(state.getCurrentContent());
    const htmlContent = draftToHtml(rawContentState);
    const sanitizedContent = DOMPurify.sanitize(htmlContent); // Sanitize HTML
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
