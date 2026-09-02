"use client";

import React, { useState, useEffect, useRef } from "react";
import { MessageSquare, Send, User, Search, Clock, Check, CheckCheck, XCircle } from "lucide-react";
import io from "socket.io-client";
import { fetchWithAuth } from "@/lib/api";
import { useSearchParams } from "next/navigation";

const formatDividerDate = (dateString) => {
  if (!dateString) return "";
  const msgDate = new Date(dateString);
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const msgDay = new Date(msgDate);
  msgDay.setHours(0, 0, 0, 0);
  
  const diffTime = today - msgDay;
  const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));

  if (diffDays === 0) return "Today";
  if (diffDays === 1) return "Yesterday";
  if (diffDays > 1 && diffDays < 7) {
    return msgDate.toLocaleDateString(undefined, { weekday: 'long' });
  }
  return msgDate.toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' });
};

export default function ChatInbox() {
  const [tickets, setTickets] = useState([]);
  const [selectedTicketId, setSelectedTicketId] = useState(null);
  const [ticketFilter, setTicketFilter] = useState("open");
  const [messages, setMessages] = useState([]);
  const [inputText, setInputText] = useState("");
  const [socket, setSocket] = useState(null);
  const [searchQuery, setSearchQuery] = useState("");
  const messagesEndRef = useRef(null);
  const searchParams = useSearchParams();

  // 1. Initialize socket connection
  useEffect(() => {
    const token = localStorage.getItem('admin_auth_token');
    const newSocket = io(process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5000', {
      auth: { token }
    });

    setSocket(newSocket);

    newSocket.on("connect", () => {
      console.log("Connected to chat server");
    });

    newSocket.on("receive_message", (message) => {
      console.log("Frontend received message:", message);
      setMessages((prev) => {
        if (selectedTicketId && message.ticketId === selectedTicketId) {
          if (!prev.find(m => m._id === message._id)) {
            return [...prev, message];
          }
        }
        return prev;
      });

      // Update the recent tickets list
      loadTickets();
    });

    return () => newSocket.close();
  }, [selectedTicketId]);

  // 2. Load recent tickets on mount
  useEffect(() => {
    loadTickets().then((loadedTickets) => {
      // Auto-select ticket if passed in URL
      const ticketIdFromUrl = searchParams.get('ticketId');
      if (ticketIdFromUrl) {
        setSelectedTicketId(ticketIdFromUrl);
      }
    });
  }, [searchParams]);

  const loadTickets = async () => {
    try {
      const data = await fetchWithAuth('/tickets');
      if (data.success) {
        setTickets(data.tickets);
        return data.tickets;
      }
      return [];
    } catch (err) {
      console.error("Failed to load tickets", err);
      return [];
    }
  };

  // 3. Load full chat history when a ticket is selected
  useEffect(() => {
    if (selectedTicketId) {
      loadTicketHistory(selectedTicketId);
      const selectedTicket = tickets.find(t => t._id === selectedTicketId);
      // Mark as read
      if (socket && selectedTicket) {
        socket.emit("mark_as_read", { senderId: selectedTicket.userId, ticketId: selectedTicketId });
        loadTickets(); // refresh read status in sidebar
      }
    }
  }, [selectedTicketId, socket]);

  const loadTicketHistory = async (ticketId) => {
    try {
      const data = await fetchWithAuth(`/tickets/${ticketId}/messages`);
      if (data.success) {
        setMessages(data.messages);
      }
    } catch (err) {
      console.error("Failed to load ticket history", err);
    }
  };

  // 4. Scroll to bottom whenever messages change
  useEffect(() => {
    if (messagesEndRef.current) {
      messagesEndRef.current.scrollIntoView({ behavior: "smooth" });
    }
  }, [messages]);

  const sendMessage = (e) => {
    e.preventDefault();
    if (!inputText.trim() || !selectedTicketId || !socket) return;
    
    const selectedTicket = tickets.find(t => t._id === selectedTicketId);
    if (!selectedTicket || selectedTicket.status === 'closed') return;

    const messageData = {
      receiverId: selectedTicket.userId,
      text: inputText,
      ticketId: selectedTicketId
    };
    
    socket.emit("send_message", messageData);
    setInputText("");
  };

  const closeTicket = async () => {
    if (!selectedTicketId) return;
    try {
      const data = await fetchWithAuth(`/tickets/${selectedTicketId}/close`, { method: 'PATCH' });
      if (data.success) {
        loadTickets();
        setSelectedTicketId(null);
      }
    } catch (err) {
      console.error("Failed to close ticket", err);
    }
  };

  // Filter tickets by search and status
  const filteredTickets = tickets.filter(t => 
    t.status === ticketFilter &&
    (t.subject?.toLowerCase().includes(searchQuery.toLowerCase()) ||
    t.user?.displayName?.toLowerCase().includes(searchQuery.toLowerCase()) ||
    t.user?.email?.toLowerCase().includes(searchQuery.toLowerCase()))
  );

  const selectedTicket = tickets.find(t => t._id === selectedTicketId);

  return (
    <div className="h-[calc(100vh-6rem)] -m-4 md:-m-8 bg-white border border-slate-200 shadow-sm flex overflow-hidden lg:rounded-2xl">
      
      {/* Sidebar: Ticket List */}
      <div className={`w-full md:w-80 border-r border-slate-200 bg-slate-50 flex flex-col ${selectedTicketId ? 'hidden md:flex' : 'flex'}`}>
        <div className="p-4 border-b border-slate-200 bg-white">
          <h2 className="text-xl font-bold text-slate-800 flex items-center gap-2 mb-4">
            <MessageSquare className="w-5 h-5 text-teal-500" />
            Support Tickets
          </h2>
          <div className="flex gap-2 mb-4">
            <button 
              onClick={() => setTicketFilter('open')}
              className={`flex-1 py-1 text-sm font-medium rounded-md ${ticketFilter === 'open' ? 'bg-teal-50 text-teal-700 border border-teal-200' : 'text-slate-500 hover:bg-slate-100'}`}
            >
              Open
            </button>
            <button 
              onClick={() => setTicketFilter('closed')}
              className={`flex-1 py-1 text-sm font-medium rounded-md ${ticketFilter === 'closed' ? 'bg-slate-200 text-slate-700 border border-slate-300' : 'text-slate-500 hover:bg-slate-100'}`}
            >
              Closed
            </button>
          </div>
          <div className="relative">
            <Search className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
            <input 
              type="text" 
              placeholder="Search tickets..." 
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-9 pr-4 py-2 bg-slate-100 border-none rounded-xl text-sm focus:ring-2 focus:ring-teal-500/20 outline-none"
            />
          </div>
        </div>

        <div className="flex-1 overflow-y-auto">
          {filteredTickets.map((ticket) => (
            <button 
              key={ticket._id}
              onClick={() => setSelectedTicketId(ticket._id)}
              className={`w-full text-left p-4 border-b border-slate-100 hover:bg-slate-100 transition-colors flex gap-3 ${selectedTicketId === ticket._id ? 'bg-teal-50/50' : ''}`}
            >
              <div className="relative">
                <div className="w-10 h-10 bg-teal-100 rounded-full flex items-center justify-center text-teal-600 font-bold overflow-hidden">
                  {ticket.user?.photoUrl ? (
                    <img src={ticket.user.photoUrl} alt="Profile" className="w-full h-full object-cover" />
                  ) : (
                    ticket.user?.displayName?.charAt(0).toUpperCase() || <User className="w-5 h-5" />
                  )}
                </div>
                {ticket.lastMessage?.senderId === ticket.userId && !ticket.lastMessage?.isRead && (
                  <div className="absolute -top-1 -right-1 w-3 h-3 bg-red-500 rounded-full border-2 border-white"></div>
                )}
              </div>
              
              <div className="flex-1 min-w-0">
                <div className="flex justify-between items-baseline mb-1">
                  <h4 className="font-bold text-sm text-slate-800 truncate pr-2">
                    {ticket.subject}
                  </h4>
                  <span className="text-[10px] text-slate-400 whitespace-nowrap">
                    {ticket.lastMessage ? new Date(ticket.lastMessage.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : ''}
                  </span>
                </div>
                <p className="text-xs text-slate-500 mb-1">
                  {ticket.user?.displayName || ticket.user?.email || "Unknown User"}
                </p>
                <p className={`text-xs truncate ${ticket.lastMessage?.senderId === ticket.userId && !ticket.lastMessage?.isRead ? 'font-bold text-slate-800' : 'text-slate-400'}`}>
                  {ticket.lastMessage ? (ticket.lastMessage.senderId === 'admin' ? 'You: ' + ticket.lastMessage.text : ticket.lastMessage.text) : 'No messages yet'}
                </p>
              </div>
            </button>
          ))}
          
          {filteredTickets.length === 0 && (
            <div className="p-8 text-center text-slate-500 flex flex-col items-center">
              <MessageSquare className="w-8 h-8 text-slate-300 mb-2" />
              <p className="text-sm">No tickets found.</p>
            </div>
          )}
        </div>
      </div>

      {/* Main Chat Area */}
      {selectedTicketId ? (
        <div className={`flex-1 flex flex-col bg-white ${!selectedTicketId ? 'hidden md:flex' : 'flex'}`}>
          {/* Chat Header */}
          <div className="p-4 border-b border-slate-200 bg-white flex items-center justify-between">
            <div className="flex items-center gap-3">
              <button 
                onClick={() => setSelectedTicketId(null)}
                className="md:hidden p-2 -ml-2 text-slate-500 hover:bg-slate-100 rounded-lg"
              >
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" /></svg>
              </button>
              <div>
                <h3 className="font-bold text-slate-800 flex items-center gap-2">
                  {selectedTicket?.subject}
                  {selectedTicket?.status === 'closed' && (
                    <span className="bg-slate-200 text-slate-600 text-xs px-2 py-0.5 rounded-full">Closed</span>
                  )}
                </h3>
                <p className="text-xs text-slate-500">
                  {selectedTicket?.user?.displayName || selectedTicket?.user?.email} • {selectedTicket?.user?.phone || 'No phone'}
                </p>
              </div>
            </div>
            {selectedTicket?.status === 'open' && (
              <button 
                onClick={closeTicket}
                className="text-sm bg-red-50 text-red-600 hover:bg-red-100 px-3 py-1.5 rounded-lg font-medium transition-colors flex items-center gap-1"
              >
                <XCircle className="w-4 h-4" />
                Close Ticket
              </button>
            )}
          </div>

          {/* Messages */}
          <div className="flex-1 overflow-y-auto p-4 space-y-4 bg-slate-50">
            {messages.map((msg, idx) => {
              const isAdmin = msg.senderId === 'admin';
              
              // Group date headers logic
              let showDateDivider = false;
              let dateText = "";
              if (idx === 0) {
                showDateDivider = true;
                dateText = formatDividerDate(msg.createdAt);
              } else {
                const prevMsg = messages[idx - 1];
                const prevDate = new Date(prevMsg.createdAt);
                prevDate.setHours(0,0,0,0);
                const currDate = new Date(msg.createdAt);
                currDate.setHours(0,0,0,0);
                if (prevDate.getTime() !== currDate.getTime()) {
                  showDateDivider = true;
                  dateText = formatDividerDate(msg.createdAt);
                }
              }
              
              return (
                <div key={msg._id || idx} className="flex flex-col">
                  {showDateDivider && (
                    <div className="flex justify-center my-4">
                      <div className="bg-slate-200 text-slate-500 text-xs px-3 py-1 rounded-full font-medium shadow-sm">
                        {dateText}
                      </div>
                    </div>
                  )}
                  <div className={`flex ${isAdmin ? 'justify-end' : 'justify-start'} mb-1`}>
                    <div className={`max-w-[75%] rounded-2xl px-4 py-2 ${
                      isAdmin 
                        ? 'bg-teal-600 text-white rounded-br-sm' 
                        : 'bg-white border border-slate-200 text-slate-800 rounded-bl-sm shadow-sm'
                    }`}>
                      <p className="text-sm whitespace-pre-wrap break-words">{msg.text}</p>
                      <div className={`flex items-center justify-end gap-1 mt-1 ${isAdmin ? 'text-teal-100' : 'text-slate-400'}`}>
                        <span className="text-[10px]">
                          {new Date(msg.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                        </span>
                        {isAdmin && (
                          msg.isRead ? <CheckCheck className="w-3 h-3" /> : <Check className="w-3 h-3" />
                        )}
                      </div>
                    </div>
                  </div>
                </div>
              );
            })}
            <div ref={messagesEndRef} />
          </div>

          {/* Input Area */}
          {selectedTicket?.status === 'open' ? (
            <div className="p-4 bg-white border-t border-slate-200">
              <form onSubmit={sendMessage} className="flex gap-2">
                <input
                  type="text"
                  value={inputText}
                  onChange={(e) => setInputText(e.target.value)}
                  placeholder="Type your message..."
                  className="flex-1 bg-slate-100 border-none rounded-xl px-4 py-3 text-sm focus:ring-2 focus:ring-teal-500/20 outline-none"
                />
                <button 
                  type="submit"
                  disabled={!inputText.trim()}
                  className="bg-teal-500 hover:bg-teal-600 disabled:opacity-50 disabled:hover:bg-teal-500 text-white p-3 rounded-xl transition-colors shadow-sm"
                >
                  <Send className="w-5 h-5" />
                </button>
              </form>
            </div>
          ) : (
            <div className="p-4 bg-slate-100 border-t border-slate-200 text-center text-slate-500 text-sm">
              This ticket is closed. No further messages can be sent.
            </div>
          )}
        </div>
      ) : (
        <div className="hidden md:flex flex-1 flex-col items-center justify-center bg-slate-50 text-slate-400">
          <MessageSquare className="w-16 h-16 mb-4 text-slate-200" />
          <h3 className="text-xl font-bold text-slate-600 mb-2">Support Tickets</h3>
          <p>Select a ticket from the sidebar to view details</p>
        </div>
      )}
    </div>
  );
}
