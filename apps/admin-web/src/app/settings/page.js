"use client";

import { Settings, Shield, Bell, Save, Store, X } from "lucide-react";
import { useState, useEffect } from "react";
import TwoFactorModal from "@/components/settings/TwoFactorModal";

const tabs = [
  { id: "general", label: "General", icon: Settings },
  { id: "fees", label: "Store Fees", icon: Store },
  { id: "support", label: "Support & FAQs", icon: Settings },
  { id: "security", label: "Security", icon: Shield },
  { id: "notifications", label: "Notifications", icon: Bell },
];

export default function SettingsPage() {
  const [activeTab, setActiveTab] = useState("general");
  const [logoPreview, setLogoPreview] = useState("https://api.dicebear.com/7.x/shapes/svg?seed=Nilara");
  const [is2FAEnabled, setIs2FAEnabled] = useState(false);
  const [is2FAModalOpen, setIs2FAModalOpen] = useState(false);
  const [twoFactorMode, setTwoFactorMode] = useState('enable');
  
  const [storeSettings, setStoreSettings] = useState({
    handlingCharge: 2,
    deliveryFee: 25,
    freeDeliveryMinAmount: 500,
    contactSupport: {
      phone: 'Available 9 AM to 8 PM',
      email: 'support@nilara.com',
      chatResponseTime: 'Usually replies within 5 minutes'
    },
    faqs: []
  });
  const [isLoadingSettings, setIsLoadingSettings] = useState(false);

  useEffect(() => {
    const fetchSettings = async () => {
      try {
        const res = await fetch('http://localhost:5000/api/v1/settings');
        const data = await res.json();
        if (data.success && data.data) {
          setStoreSettings(data.data);
        }
      } catch (err) {
        console.error("Error fetching settings", err);
      }
    };
    fetchSettings();
  }, []);

  const handleSaveSettings = async () => {
    if (activeTab === 'fees' || activeTab === 'general' || activeTab === 'support') {
      setIsLoadingSettings(true);
      try {
        const res = await fetch('http://localhost:5000/api/v1/settings', {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(storeSettings)
        });
        const data = await res.json();
        if (data.success) {
          alert('Settings updated successfully!');
        }
      } catch (err) {
        console.error("Error saving settings", err);
        alert('Failed to save settings');
      } finally {
        setIsLoadingSettings(false);
      }
    } else {
      alert('Settings saved!');
    }
  };

  const handleLogoChange = (e) => {
    if (e.target.files && e.target.files[0]) {
      const reader = new FileReader();
      reader.onload = (e) => setLogoPreview(e.target.result);
      reader.readAsDataURL(e.target.files[0]);
    }
  };

  return (
    <div className="max-w-[1200px] mx-auto pb-10">
      
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between mb-8 gap-4">
        <div>
          <h1 className="text-3xl font-black text-slate-800 tracking-tight mb-1">Settings</h1>
          <p className="text-sm font-medium text-slate-500">Manage your application preferences and system configurations.</p>
        </div>
        <button 
          onClick={handleSaveSettings}
          disabled={isLoadingSettings}
          className="flex items-center px-6 py-2.5 bg-teal-600 text-white rounded-xl text-sm font-bold hover:bg-teal-700 transition-colors shadow-sm disabled:opacity-50"
        >
          <Save className="w-4 h-4 mr-2" />
          {isLoadingSettings ? 'Saving...' : 'Save Settings'}
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        
        {/* Sidebar */}
        {/* Sidebar */}
        <div className="md:col-span-1 flex gap-2 md:block md:space-y-2">
          {tabs.map((tab) => {
            const Icon = tab.icon;
            const isActive = activeTab === tab.id;
            return (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`flex-1 flex justify-center md:justify-start items-center px-2 py-2.5 md:px-4 md:py-3 rounded-xl md:rounded-2xl text-[11px] sm:text-xs md:text-sm font-bold transition-colors md:w-full ${
                  isActive 
                    ? 'bg-slate-800 text-white shadow-sm' 
                    : 'bg-white text-slate-600 hover:bg-slate-50 border border-slate-100 hover:border-slate-200 shadow-[0_4px_20px_rgb(0,0,0,0.02)]'
                }`}
              >
                <Icon className={`w-3 h-3 sm:w-3.5 sm:h-3.5 md:w-4 md:h-4 mr-1.5 md:mr-3 ${isActive ? 'text-teal-400' : 'text-slate-400'}`} />
                {tab.label}
              </button>
            );
          })}
        </div>

        {/* Content Area */}
        <div className="md:col-span-3 bg-white rounded-3xl border border-slate-100 shadow-[0_4px_20px_rgb(0,0,0,0.03)] p-6 sm:p-8 min-h-[500px]">
          
          {activeTab === "general" && (
            <div className="space-y-8 animate-in fade-in duration-300">
              <div>
                <h3 className="text-lg font-black text-slate-800 mb-1">General Preferences</h3>
                <p className="text-xs font-medium text-slate-500 mb-6">Update your basic application settings.</p>
                
                <div className="space-y-6 max-w-lg">
                  {/* Logo Uploader */}
                  <div>
                    <label className="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-2">Platform Logo</label>
                    <div className="flex items-center space-x-4">
                      <div className="w-16 h-16 rounded-xl border border-slate-200 bg-slate-50 flex items-center justify-center overflow-hidden shrink-0 shadow-sm">
                        {logoPreview ? (
                          <img src={logoPreview} alt="Logo" className="w-full h-full object-cover" />
                        ) : (
                          <span className="text-xl font-bold text-slate-300">N</span>
                        )}
                      </div>
                      <div className="flex-1">
                        <div className="flex items-center space-x-2">
                          <label className="px-4 py-2 bg-teal-50 text-teal-600 rounded-lg text-xs font-bold hover:bg-teal-100 transition-colors cursor-pointer shadow-sm border border-teal-100/50">
                            Upload Photo
                            <input type="file" className="hidden" accept="image/*" onChange={handleLogoChange} />
                          </label>
                          <button 
                            onClick={() => setLogoPreview(null)}
                            className="px-4 py-2 bg-slate-50 text-slate-600 rounded-lg text-xs font-bold hover:bg-slate-100 transition-colors border border-slate-200"
                          >
                            Remove
                          </button>
                        </div>
                        <p className="text-[10px] font-medium text-slate-400 mt-2">Recommended size: 256x256px. Max file size: 2MB.</p>
                      </div>
                    </div>
                  </div>

                  <div>
                    <label className="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-2">Platform Name</label>
                    <input 
                      type="text" 
                      defaultValue="Nilara Delivery" 
                      className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm font-bold text-slate-700 focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all" 
                    />
                  </div>
                  <div>
                    <label className="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-2">Support Email</label>
                    <input 
                      type="email" 
                      defaultValue="support@nilara.com" 
                      className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm font-bold text-slate-700 focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all" 
                    />
                  </div>
                  <div>
                    <label className="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-2">Timezone</label>
                    <select className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm font-bold text-slate-700 focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all cursor-pointer">
                      <option>(GMT+05:30) Chennai, Kolkata, Mumbai, New Delhi</option>
                      <option>(GMT+00:00) London</option>
                      <option>(GMT-05:00) Eastern Time (US & Canada)</option>
                    </select>
                  </div>
                  
                  <div className="pt-4 border-t border-slate-100">
                    <label className="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-2">Delivery Time Slots</label>
                    <p className="text-xs text-slate-500 mb-3">Define the time slots available for customers to choose from.</p>
                    <div className="space-y-2">
                      {(storeSettings.deliveryTimeSlots || []).map((slot, index) => (
                        <div key={index} className="flex items-center gap-2">
                          <input 
                            type="text" 
                            value={slot}
                            onChange={(e) => {
                              const newSlots = [...(storeSettings.deliveryTimeSlots || [])];
                              newSlots[index] = e.target.value;
                              setStoreSettings({ ...storeSettings, deliveryTimeSlots: newSlots });
                            }}
                            className="flex-1 px-4 py-2 bg-white border border-slate-200 rounded-lg text-sm font-semibold text-slate-700 focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all" 
                          />
                          <button 
                            type="button"
                            onClick={() => {
                              const newSlots = (storeSettings.deliveryTimeSlots || []).filter((_, i) => i !== index);
                              setStoreSettings({ ...storeSettings, deliveryTimeSlots: newSlots });
                            }}
                            className="p-2 text-red-500 hover:bg-red-50 rounded-lg transition-colors"
                          >
                            <X className="w-4 h-4" />
                          </button>
                        </div>
                      ))}
                    </div>
                    <button 
                      type="button"
                      onClick={() => {
                        const newSlots = [...(storeSettings.deliveryTimeSlots || []), "New Time Slot"];
                        setStoreSettings({ ...storeSettings, deliveryTimeSlots: newSlots });
                      }}
                      className="mt-3 text-xs font-bold text-teal-600 hover:text-teal-700 bg-teal-50 hover:bg-teal-100 px-3 py-1.5 rounded-lg transition-colors inline-block"
                    >
                      + Add Time Slot
                    </button>
                  </div>
                </div>
              </div>
            </div>
          )}

          {activeTab === "fees" && (
            <div className="space-y-8 animate-in fade-in duration-300">
              <div>
                <h3 className="text-lg font-black text-slate-800 mb-1">Store Fees & Thresholds</h3>
                <p className="text-xs font-medium text-slate-500 mb-6">Manage global cart charges like delivery fees and handling.</p>
                
                <div className="space-y-6 max-w-lg">
                  <div>
                    <label className="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-2">Handling Charge (₹)</label>
                    <input 
                      type="number" 
                      value={storeSettings.handlingCharge}
                      onChange={(e) => setStoreSettings({...storeSettings, handlingCharge: Number(e.target.value)})}
                      className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm font-bold text-slate-700 focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all" 
                    />
                  </div>
                  <div>
                    <label className="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-2">Standard Delivery Fee (₹)</label>
                    <input 
                      type="number" 
                      value={storeSettings.deliveryFee}
                      onChange={(e) => setStoreSettings({...storeSettings, deliveryFee: Number(e.target.value)})}
                      className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm font-bold text-slate-700 focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all" 
                    />
                  </div>
                  <div>
                    <label className="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-2">Free Delivery Minimum Amount (₹)</label>
                    <input 
                      type="number" 
                      value={storeSettings.freeDeliveryMinAmount || 500}
                      onChange={(e) => setStoreSettings({...storeSettings, freeDeliveryMinAmount: Number(e.target.value)})}
                      className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm font-bold text-slate-700 focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all" 
                    />
                    <p className="text-[10px] font-medium text-slate-400 mt-2">If item total exceeds this amount, delivery fee will be FREE.</p>
                  </div>
                  <div>
                    <label className="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-2">Custom Design Min Order Quantity</label>
                    <input 
                      type="number" 
                      value={storeSettings.customDesignMinOrder || 100}
                      onChange={(e) => setStoreSettings({...storeSettings, customDesignMinOrder: Number(e.target.value)})}
                      className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm font-bold text-slate-700 focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all" 
                    />
                  </div>
                  <div>
                    <label className="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-2">Custom Design Surcharge (₹ per bottle)</label>
                    <input 
                      type="number" 
                      value={storeSettings.customDesignSurcharge || 10}
                      onChange={(e) => setStoreSettings({...storeSettings, customDesignSurcharge: Number(e.target.value)})}
                      className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm font-bold text-slate-700 focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all" 
                    />
                  </div>
                </div>
              </div>
            </div>
          )}

          {activeTab === "support" && (
            <div className="space-y-8 animate-in fade-in duration-300">
              <div>
                <h3 className="text-lg font-black text-slate-800 mb-1">Support & FAQs</h3>
                <p className="text-xs font-medium text-slate-500 mb-6">Manage customer support contact details and frequently asked questions.</p>
                
                <div className="space-y-6 max-w-2xl">
                  <div className="space-y-4">
                    <div>
                      <label className="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-2">Support Email</label>
                      <input 
                        type="email" 
                        value={storeSettings.contactSupport?.email || ''}
                        onChange={(e) => setStoreSettings({...storeSettings, contactSupport: {...storeSettings.contactSupport, email: e.target.value}})}
                        className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm font-bold text-slate-700 focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all" 
                      />
                    </div>
                  </div>
                  <div>
                    <label className="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-2">Chat Response Time Message</label>
                    <input 
                      type="text" 
                      value={storeSettings.contactSupport?.chatResponseTime || ''}
                      onChange={(e) => setStoreSettings({...storeSettings, contactSupport: {...storeSettings.contactSupport, chatResponseTime: e.target.value}})}
                      className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm font-bold text-slate-700 focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all" 
                    />
                  </div>

                  <div className="pt-4 border-t border-slate-100">
                    <label className="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-2">Frequently Asked Questions (FAQs)</label>
                    <div className="space-y-4">
                      {(storeSettings.faqs || []).map((faq, index) => (
                        <div key={index} className="flex gap-2 items-start border border-slate-200 p-4 rounded-xl bg-slate-50">
                          <div className="flex-1 space-y-3">
                            <input 
                              type="text" 
                              placeholder="Question"
                              value={faq.question}
                              onChange={(e) => {
                                const newFaqs = [...(storeSettings.faqs || [])];
                                newFaqs[index].question = e.target.value;
                                setStoreSettings({ ...storeSettings, faqs: newFaqs });
                              }}
                              className="w-full px-4 py-2 bg-white border border-slate-200 rounded-lg text-sm font-semibold text-slate-700 focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all" 
                            />
                            <textarea 
                              placeholder="Answer"
                              value={faq.answer}
                              onChange={(e) => {
                                const newFaqs = [...(storeSettings.faqs || [])];
                                newFaqs[index].answer = e.target.value;
                                setStoreSettings({ ...storeSettings, faqs: newFaqs });
                              }}
                              className="w-full px-4 py-2 bg-white border border-slate-200 rounded-lg text-sm font-medium text-slate-700 focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all h-20 resize-none" 
                            />
                          </div>
                          <button 
                            type="button"
                            onClick={() => {
                              const newFaqs = (storeSettings.faqs || []).filter((_, i) => i !== index);
                              setStoreSettings({ ...storeSettings, faqs: newFaqs });
                            }}
                            className="p-2 text-red-500 hover:bg-red-50 rounded-lg transition-colors mt-1"
                          >
                            <X className="w-5 h-5" />
                          </button>
                        </div>
                      ))}
                    </div>
                    <button 
                      type="button"
                      onClick={() => {
                        const newFaqs = [...(storeSettings.faqs || []), { question: '', answer: '' }];
                        setStoreSettings({ ...storeSettings, faqs: newFaqs });
                      }}
                      className="mt-4 text-sm font-bold text-teal-600 hover:text-teal-700 bg-teal-50 hover:bg-teal-100 px-4 py-2 rounded-lg transition-colors inline-block"
                    >
                      + Add FAQ
                    </button>
                  </div>
                </div>
              </div>
            </div>
          )}

          {activeTab === "security" && (
            <div className="space-y-8 animate-in fade-in duration-300">
              <div>
                <h3 className="text-lg font-black text-slate-800 mb-1">Security Settings</h3>
                <p className="text-xs font-medium text-slate-500 mb-6">Manage your password and security preferences.</p>
                
                <div className="space-y-5 max-w-lg">
                  <div>
                    <label className="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-2">Current Password</label>
                    <input 
                      type="password" 
                      placeholder="Enter current password" 
                      className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm font-bold text-slate-700 focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all" 
                    />
                  </div>
                  <div>
                    <label className="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-2">New Password</label>
                    <input 
                      type="password" 
                      placeholder="Enter new password" 
                      className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm font-bold text-slate-700 focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all" 
                    />
                  </div>
                  <div>
                    <label className="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-2">Confirm New Password</label>
                    <input 
                      type="password" 
                      placeholder="Confirm new password" 
                      className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm font-bold text-slate-700 focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all" 
                    />
                  </div>
                  
                  <div className="pt-4 border-t border-slate-100">
                    <label className="flex items-center space-x-3 cursor-pointer">
                      <div className="relative">
                        <input 
                          type="checkbox" 
                          className="sr-only peer" 
                          checked={is2FAEnabled}
                          onChange={(e) => {
                            setTwoFactorMode(e.target.checked ? 'enable' : 'disable');
                            setIs2FAModalOpen(true);
                          }}
                        />
                        <div className="w-10 h-5 bg-slate-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-slate-300 after:border after:rounded-full after:h-4 after:w-4 after:transition-all peer-checked:bg-teal-500"></div>
                      </div>
                      <span className="text-sm font-bold text-slate-700">Enable Two-Factor Authentication (2FA)</span>
                    </label>
                  </div>
                </div>
              </div>
            </div>
          )}

          {activeTab === "notifications" && (
            <div className="space-y-8 animate-in fade-in duration-300">
              <div>
                <h3 className="text-lg font-black text-slate-800 mb-1">Notification Preferences</h3>
                <p className="text-xs font-medium text-slate-500 mb-6">Choose what you want to be notified about.</p>
                
                <div className="space-y-4 max-w-lg">
                  {[
                    { id: "n1", label: "New Order Alerts", desc: "Receive alerts for every new order placed." },
                    { id: "n2", label: "Delivery Delays", desc: "Get notified when a driver is delayed." },
                    { id: "n3", label: "System Alerts", desc: "Server downtime or maintenance warnings." },
                    { id: "n4", label: "Weekly Reports", desc: "Receive a summary of sales every Monday." },
                  ].map((item) => (
                    <div key={item.id} className="flex items-start space-x-4 p-4 rounded-2xl border border-slate-100 hover:bg-slate-50 transition-colors">
                      <div className="relative mt-1 shrink-0">
                        <input type="checkbox" className="sr-only peer" defaultChecked={item.id !== "n4"} />
                        <div className="w-10 h-5 bg-slate-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-slate-300 after:border after:rounded-full after:h-4 after:w-4 after:transition-all peer-checked:bg-teal-500"></div>
                      </div>
                      <div>
                        <h4 className="text-sm font-bold text-slate-800">{item.label}</h4>
                        <p className="text-xs font-medium text-slate-500 mt-0.5">{item.desc}</p>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          )}

          
        </div>
      </div>
      
      <TwoFactorModal 
        isOpen={is2FAModalOpen} 
        onClose={() => setIs2FAModalOpen(false)} 
        onSuccess={() => setIs2FAEnabled(twoFactorMode === 'enable')} 
        mode={twoFactorMode}
      />
    </div>
  );
}
