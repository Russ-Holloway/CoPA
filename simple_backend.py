#!/usr/bin/env python3
"""
Simple mock backend for development - returns dummy responses to test UI layout
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import json
import time

app = Flask(__name__)
CORS(app)

# Mock response data
MOCK_RESPONSE = {
    "id": "chatcmpl-mock",
    "object": "chat.completion",
    "created": int(time.time()),
    "model": "gpt-35-turbo",
    "choices": [{
        "index": 0,
        "message": {
            "role": "assistant", 
            "content": "This is a mock response from CoPPA to test the citation panel layout. This response demonstrates how the answer area works alongside the citation panel when both are displayed. [1] The citation panel should appear with appropriate spacing when citations are clicked."
        },
        "finish_reason": "stop"
    }],
    "usage": {
        "prompt_tokens": 50,
        "completion_tokens": 100,
        "total_tokens": 150
    }
}

MOCK_CITATIONS = [
    {
        "id": "1",
        "title": "Police Procedures Manual - Section 4.2",
        "content": "This is a mock citation content to test the citation panel layout. The content should be displayed with proper spacing and formatting. This helps demonstrate how the citation panel appears alongside the chat interface with generous but appropriate spacing as requested by the user.",
        "url": "https://example.com/police-procedures#section-4-2",
        "metadata": {
            "source": "Police Procedures Manual",
            "section": "4.2",
            "page": 42
        }
    }
]

@app.route('/')
def index():
    return "Mock CoPPA Backend - UI Testing Server"

@app.route('/ask', methods=['POST'])
def ask():
    """Mock ask endpoint that returns a canned response with citations"""
    try:
        data = request.get_json()
        question = data.get('question', '')
        
        # Return mock response
        response = {
            "answer": MOCK_RESPONSE["choices"][0]["message"]["content"],
            "citations": MOCK_CITATIONS,
            "message_id": "mock-message-123",
            "conversation_id": "mock-conversation-456"
        }
        
        return jsonify(response)
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/conversation', methods=['GET', 'POST'])
def conversation():
    """Mock conversation endpoint - handles both GET and POST"""
    if request.method == 'GET':
        return jsonify({
            "conversation_id": "mock-conversation-456",
            "messages": []
        })
    elif request.method == 'POST':
        try:
            data = request.get_json()
            print(f"Received conversation request: {data}")
            
            # Handle streaming chat response
            def generate():
                # First yield the tool message with citations
                tool_data = {
                    "id": "mock-message-123",
                    "choices": [{
                        "messages": [{
                            "role": "tool",
                            "content": json.dumps({"citations": MOCK_CITATIONS})
                        }]
                    }]
                }
                print(f"Sending tool response: {tool_data}")
                yield json.dumps(tool_data) + '\n'
                
                # Then yield the assistant message with content
                assistant_data = {
                    "id": "mock-message-123", 
                    "choices": [{
                        "messages": [{
                            "role": "assistant",
                            "content": "This is a mock response from CoPPA to test the citation panel layout. This response demonstrates how the answer area works alongside the citation panel when both are displayed. [1] The citation panel should appear with appropriate spacing when citations are clicked.",
                            "end_turn": True
                        }]
                    }]
                }
                print(f"Sending assistant response: {assistant_data}")
                yield json.dumps(assistant_data) + '\n'
            
            return app.response_class(generate(), mimetype='application/json')
            
        except Exception as e:
            print(f"Error in conversation endpoint: {e}")
            return jsonify({"error": str(e)}), 500@app.route('/history/ensure', methods=['GET', 'POST'])
def history_ensure():
    """Mock history ensure endpoint"""
    return jsonify({"success": True})

@app.route('/chat', methods=['POST'])
def chat():
    """Mock chat endpoint - similar to ask but for chat interface"""
    try:
        data = request.get_json()
        question = data.get('messages', [{}])[-1].get('content', '') if data.get('messages') else data.get('question', '')
        
        # Return mock response
        response = {
            "choices": [{
                "delta": {
                    "content": MOCK_RESPONSE["choices"][0]["message"]["content"]
                },
                "index": 0,
                "finish_reason": "stop"
            }],
            "citations": MOCK_CITATIONS,
            "message_id": "mock-message-123",
            "conversation_id": "mock-conversation-456"
        }
        
        return jsonify(response)
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/frontend_settings', methods=['GET'])
def frontend_settings():
    """Mock frontend settings endpoint"""
    return jsonify({
        "ui": {
            "title": "CoPPA",
            "logo": None,
            "chat_logo": None,
            "chat_title": "CoPPA", 
            "favicon": None,
            "show_share_button": False,
            "feedback_enabled": False,
            "auth_enabled": False,
            "police_force_tagline": "College of Policing Assistant",
            "police_force_tagline_2": "Helping law enforcement with reliable guidance"
        },
        "auth_enabled": False
    })

@app.route('/history/list', methods=['GET'])
def history_list():
    """Mock history endpoint"""
    return jsonify([])

@app.route('/history/generate', methods=['POST'])
def history_generate():
    """Mock history generate endpoint"""
    try:
        data = request.get_json()
        print(f"Received history/generate request: {data}")
        
        # Handle streaming chat response
        def generate():
            # First yield the tool message with citations
            tool_data = {
                "id": "mock-message-123",
                "choices": [{
                    "messages": [{
                        "role": "tool",
                        "content": json.dumps({"citations": MOCK_CITATIONS})
                    }]
                }]
            }
            print(f"Sending tool response: {tool_data}")
            yield json.dumps(tool_data) + '\n'
            
            # Then yield the assistant message with content
            assistant_data = {
                "id": "mock-message-123", 
                "choices": [{
                    "messages": [{
                        "role": "assistant",
                        "content": "This is a mock response from CoPPA to test the citation panel layout. This response demonstrates how the answer area works alongside the citation panel when both are displayed. [1] The citation panel should appear with appropriate spacing when citations are clicked.",
                        "end_turn": True
                    }]
                }]
            }
            print(f"Sending assistant response: {assistant_data}")
            yield json.dumps(assistant_data) + '\n'
            
        return app.response_class(generate(), mimetype='application/json')
        
    except Exception as e:
        print(f"Error in history_generate: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/history/delete', methods=['DELETE'])
def history_delete():
    """Mock history delete endpoint"""
    return jsonify({"success": True})

if __name__ == '__main__':
    print("🚀 Starting mock CoPPA backend for UI testing...")
    print("📝 This backend returns dummy responses to test citation panel layout")
    print("🌐 Frontend should connect to: http://localhost:8001")
    print("🎯 Test the citation panel by asking any question and clicking citation [1]")
    app.run(host='0.0.0.0', port=8001, debug=True)
