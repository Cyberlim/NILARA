"use client";

import { Search, Send, Trash2, ArrowLeft } from "lucide-react";
import { useState } from "react";

const mockContacts = [
  { id: 1, name: "Rahul Sharma", role: "Customer", lastMessage: "Where is my order?", time: "10:30 AM", unread: 2, avatar: "https://api.dicebear.com/7.x/notionists/svg?seed=Rahul&backgroundColor=f8fafc" },
  { id: 2, name: "Amit Kumar", role: "Driver", lastMessage: "Reached the location.", time: "09:15 AM", unread: 0, avatar: "https://api.dicebear.com/7.x/notionists/svg?seed=Amit&backgroundColor=f8fafc" },
  { id: 3, name: "Priya Patel", role: "Customer", lastMessage: "Thank you!", time: "Yesterday", unread: 0, avatar: "https://api.dicebear.com/7.x/notionists/svg?seed=Priya&backgroundColor=f8fafc" },
  { id: 4, name: "Suresh", role: "Driver", lastMessage: "Will be late by 10 mins.", time: "Yesterday", unread: 0, avatar: "https://api.dicebear.com/7.x/notionists/svg?seed=Suresh&backgroundColor=f8fafc" },
];

const mockMessages = [
  { id: 1, sender: "them", text: "Hi, I placed an order an hour ago.", time: "10:15 AM" },
  { id: 2, sender: "me", text: "Hello Rahul! Let me check the status for you.", time: "10:16 AM" },
  { id: 3, sender: "me", text: "Your order is out for delivery. It should reach you in 15 mins.", time: "10:18 AM" },
  { id: 4, sender: "them", text: "Where is my order?", time: "10:30 AM" },
];

export default function MessagesPage() {
  const [activeContact, setActiveContact] = useState(mockContacts[0]);
  const [messageInput, setMessageInput] = useState("");
  const [showChatMobile, setShowChatMobile] = useState(false);

  return (
    <div className="max-w-[1600px] mx-auto h-[calc(100vh-112px)] sm:h-[calc(100vh-144px)] flex flex-col">
      
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between mb-4 gap-4 shrink-0">
        <div>
          <h1 className="text-3xl font-black text-slate-800 tracking-tight mb-1">Messages</h1>
          <p className="text-sm font-medium text-slate-500">Communicate with customers and delivery partners.</p>
        </div>
      </div>

      {/* Chat Interface Container */}
      <div className="flex-1 bg-white rounded-3xl border border-slate-100 shadow-[0_4px_20px_rgb(0,0,0,0.03)] overflow-hidden flex min-h-0">
        
        {/* Left Sidebar - Contact List */}
        <div className={`w-full md:w-80 lg:w-96 border-r border-slate-100 flex-col shrink-0 h-full ${showChatMobile ? 'hidden md:flex' : 'flex'}`}>
          {/* Search */}
          <div className="p-4 border-b border-slate-50 shrink-0">
            <div className="relative">
              <Search className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
              <input 
                type="text" 
                placeholder="Search messages..."
                className="w-full pl-9 pr-3 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm font-medium focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all placeholder:text-slate-400"
              />
            </div>
          </div>
          
          {/* Contacts List */}
          <div className="flex-1 overflow-y-auto custom-scrollbar">
            {mockContacts.map(contact => (
              <div 
                key={contact.id}
                onClick={() => {
                  setActiveContact(contact);
                  setShowChatMobile(true);
                }}
                className={`p-4 flex items-center space-x-3 cursor-pointer transition-colors border-b border-slate-50 ${
                  activeContact.id === contact.id ? 'bg-slate-50/80' : 'hover:bg-slate-50/50'
                }`}
              >
                <div className="relative shrink-0">
                  <img src={contact.avatar} alt={contact.name} className="w-12 h-12 rounded-full border border-slate-200 bg-white" />
                  {contact.unread > 0 && (
                    <div className="absolute -top-1 -right-1 w-5 h-5 bg-teal-500 rounded-full border-2 border-white flex items-center justify-center text-[9px] font-bold text-white">
                      {contact.unread}
                    </div>
                  )}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex justify-between items-baseline mb-1">
                    <h4 className="text-sm font-bold text-slate-800 truncate pr-2">{contact.name}</h4>
                    <span className="text-[10px] font-bold text-slate-400 shrink-0">{contact.time}</span>
                  </div>
                  <div className="flex justify-between items-center">
                    <p className={`text-xs truncate pr-2 ${contact.unread > 0 ? 'font-bold text-slate-700' : 'font-medium text-slate-500'}`}>
                      {contact.lastMessage}
                    </p>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Right Area - Chat Window */}
        <div className={`flex-col min-w-0 md:flex md:flex-1 md:h-full md:bg-slate-50/30 md:relative md:inset-auto md:z-auto ${showChatMobile ? 'flex fixed inset-0 z-[60] bg-white' : 'hidden'}`}>
          
          {/* Chat Header */}
          <div className="px-4 md:px-6 py-4 bg-white border-b border-slate-100 flex justify-between items-center shrink-0">
            <div className="flex items-center space-x-3 md:space-x-4">
              <button 
                onClick={() => setShowChatMobile(false)}
                className="md:hidden w-8 h-8 flex items-center justify-center rounded-full hover:bg-slate-100 text-slate-500 transition-colors -ml-1"
              >
                <ArrowLeft className="w-5 h-5" />
              </button>
              <img src={activeContact.avatar} alt={activeContact.name} className="w-10 h-10 rounded-full border border-slate-200 bg-white" />
              <div>
                <h3 className="text-lg font-black text-slate-800 tracking-tight leading-tight">{activeContact.name}</h3>
                <span className="inline-flex px-2 py-0.5 rounded-md bg-slate-100 text-[10px] font-bold text-slate-500 mt-0.5">
                  {activeContact.role}
                </span>
              </div>
            </div>
            <div className="flex items-center space-x-2">
              <button className="flex items-center px-4 py-2 text-xs font-bold text-rose-500 bg-rose-50 hover:bg-rose-100 rounded-xl transition-colors">
                <Trash2 className="w-4 h-4 mr-1.5" />
                Clear Chat
              </button>
            </div>
          </div>

          {/* Chat Messages */}
          <div className="flex-1 overflow-y-auto p-4 md:p-6 hide-scrollbar">
            <div className="max-w-4xl mx-auto w-full space-y-6">
            
            {/* Date Divider */}
            <div className="flex justify-center">
              <span className="px-3 py-1 bg-slate-100 text-slate-500 rounded-full text-[10px] font-bold uppercase tracking-wider">
                Today
              </span>
            </div>

            {mockMessages.map(msg => (
              <div key={msg.id} className={`flex ${msg.sender === 'me' ? 'justify-end' : 'justify-start'}`}>
                <div className={`max-w-[70%] ${msg.sender === 'me' ? 'order-1' : 'order-2'}`}>
                  <div className={`p-4 rounded-2xl ${
                    msg.sender === 'me' 
                      ? 'bg-slate-800 text-white rounded-tr-sm' 
                      : 'bg-white border border-slate-100 shadow-sm text-slate-700 rounded-tl-sm'
                  }`}>
                    <p className="text-sm font-medium">{msg.text}</p>
                  </div>
                  <p className={`text-[10px] font-bold text-slate-400 mt-1.5 ${msg.sender === 'me' ? 'text-right' : 'text-left'}`}>
                    {msg.time}
                  </p>
                </div>
              </div>
            ))}
            </div>
          </div>

          {/* Chat Input */}
          <div className="p-4 bg-white border-t border-slate-100 shrink-0">
            <div className="flex items-center space-x-2 bg-slate-50 border border-slate-200 rounded-2xl p-2">
              <input 
                type="text"
                value={messageInput}
                onChange={(e) => setMessageInput(e.target.value)}
                placeholder="Type a message..."
                className="flex-1 bg-transparent border-none focus:outline-none px-4 text-sm font-medium text-slate-700 placeholder:text-slate-400"
              />
              <button className="w-10 h-10 rounded-xl bg-teal-600 hover:bg-teal-700 text-white flex items-center justify-center transition-colors shrink-0 shadow-sm">
                <Send className="w-4 h-4 ml-0.5" />
              </button>
            </div>
          </div>
        </div>

      </div>
    </div>
  );
}
