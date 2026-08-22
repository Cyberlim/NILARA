"use client";

import { useState, useEffect } from "react";
import { X, Mail, Smartphone, ArrowRight, ShieldCheck, CheckCircle2 } from "lucide-react";

export default function TwoFactorModal({ isOpen, onClose, onSuccess, mode = 'enable' }) {
  const [step, setStep] = useState('select-method'); // select-method, setup, verify, success
  const [method, setMethod] = useState(null);
  const [code, setCode] = useState("");
  const [isVerifying, setIsVerifying] = useState(false);

  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
      setStep(mode === 'enable' ? 'select-method' : 'verify');
      setMethod(mode === 'enable' ? null : 'app'); // Default to app for disable if unknown
      setCode("");
    } else {
      document.body.style.overflow = 'unset';
    }
    return () => { document.body.style.overflow = 'unset'; };
  }, [isOpen]);

  if (!isOpen) return null;

  const handleVerify = () => {
    setIsVerifying(true);
    setTimeout(() => {
      setIsVerifying(false);
      setStep('success');
      setTimeout(() => {
        onSuccess();
        onClose();
      }, 1500);
    }, 1500);
  };

  return (
    <div className="fixed inset-0 z-[110] flex items-center justify-center p-4 sm:p-6">
      <div 
        className="absolute inset-0 bg-slate-900/60 backdrop-blur-sm transition-opacity"
        onClick={onClose}
      ></div>

      <div className="relative w-full max-w-md bg-white rounded-3xl shadow-2xl flex flex-col overflow-hidden animate-in fade-in zoom-in-95 duration-200">
        
        <div className="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-white">
          <div className="flex items-center text-slate-800">
            <ShieldCheck className="w-5 h-5 mr-2 text-teal-500" />
            <h2 className="text-lg font-black tracking-tight">{mode === 'enable' ? 'Enable 2FA' : 'Disable 2FA'}</h2>
          </div>
          <button 
            onClick={onClose}
            className="w-8 h-8 flex items-center justify-center rounded-xl bg-slate-50 text-slate-400 hover:bg-slate-100 hover:text-slate-600 transition-colors"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        <div className="p-6 bg-slate-50/50">
          
          {step === 'select-method' && (
            <div className="space-y-4 animate-in fade-in slide-in-from-right-4">
              <p className="text-sm font-medium text-slate-600 mb-6">
                Choose a method to receive your two-factor authentication codes.
              </p>
              
              <button 
                onClick={() => setMethod('email')}
                className={`w-full flex items-center p-4 rounded-2xl border-2 transition-all text-left ${method === 'email' ? 'border-teal-500 bg-teal-50/50' : 'border-slate-100 bg-white hover:border-slate-200'}`}
              >
                <div className={`w-10 h-10 rounded-full flex items-center justify-center mr-4 shrink-0 ${method === 'email' ? 'bg-teal-100 text-teal-600' : 'bg-slate-100 text-slate-500'}`}>
                  <Mail className="w-5 h-5" />
                </div>
                <div className="flex-1">
                  <h4 className="text-sm font-bold text-slate-800">Email Address</h4>
                  <p className="text-xs font-medium text-slate-500 mt-0.5">Receive codes via email</p>
                </div>
              </button>

              <button 
                onClick={() => setMethod('app')}
                className={`w-full flex items-center p-4 rounded-2xl border-2 transition-all text-left ${method === 'app' ? 'border-teal-500 bg-teal-50/50' : 'border-slate-100 bg-white hover:border-slate-200'}`}
              >
                <div className={`w-10 h-10 rounded-full flex items-center justify-center mr-4 shrink-0 ${method === 'app' ? 'bg-teal-100 text-teal-600' : 'bg-slate-100 text-slate-500'}`}>
                  <Smartphone className="w-5 h-5" />
                </div>
                <div className="flex-1">
                  <h4 className="text-sm font-bold text-slate-800">Authenticator App</h4>
                  <p className="text-xs font-medium text-slate-500 mt-0.5">Use Google Authenticator or Authy</p>
                </div>
              </button>

              <div className="pt-4 mt-2">
                <button
                  onClick={() => setStep(method === 'app' ? 'setup' : 'verify')}
                  disabled={!method}
                  className="w-full py-3 bg-teal-600 hover:bg-teal-700 text-white rounded-xl text-sm font-bold transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center shadow-sm"
                >
                  Continue
                  <ArrowRight className="w-4 h-4 ml-2" />
                </button>
              </div>
            </div>
          )}

          {step === 'setup' && (
            <div className="space-y-4 animate-in fade-in slide-in-from-right-4 text-center">
              <h3 className="text-lg font-black text-slate-800">Scan QR Code</h3>
              <p className="text-xs font-medium text-slate-500 mt-1 mb-4">
                Open your authenticator app and scan this QR code to set up 2FA.
              </p>
              <div className="w-48 h-48 mx-auto bg-white border-2 border-slate-100 rounded-2xl flex items-center justify-center p-3 shadow-sm">
                <img src="https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=NilaraDelivery" alt="QR Code" className="w-full h-full object-contain" />
              </div>
              <div className="pt-4">
                <button
                  onClick={() => setStep('verify')}
                  className="w-full py-3 bg-teal-600 hover:bg-teal-700 text-white rounded-xl text-sm font-bold transition-colors shadow-sm"
                >
                  I've Scanned It
                </button>
              </div>
            </div>
          )}

          {step === 'verify' && (
            <div className="space-y-4 animate-in fade-in slide-in-from-right-4">
              <div className="text-center mb-6">
                <div className="w-12 h-12 rounded-full bg-teal-100 text-teal-600 flex items-center justify-center mx-auto mb-3">
                  {method === 'email' ? <Mail className="w-6 h-6" /> : <Smartphone className="w-6 h-6" />}
                </div>
                <h3 className="text-lg font-black text-slate-800">Enter Verification Code</h3>
                <p className="text-xs font-medium text-slate-500 mt-1">
                  {method === 'email' 
                    ? "We've sent a 6-digit code to your email." 
                    : "Enter the 6-digit code from your authenticator app."}
                </p>
              </div>

              <div>
                <input 
                  type="text"
                  maxLength={6}
                  value={code}
                  onChange={(e) => setCode(e.target.value.replace(/[^0-9]/g, ''))}
                  placeholder="000000"
                  className="w-full text-center tracking-[1em] font-mono text-2xl py-4 bg-white border border-slate-200 rounded-2xl focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all text-slate-700"
                />
              </div>

              <div className="pt-4 flex space-x-3">
                {mode === 'enable' && (
                  <button
                    onClick={() => setStep(method === 'app' ? 'setup' : 'select-method')}
                    className="flex-1 py-3 bg-white border border-slate-200 text-slate-600 hover:bg-slate-50 rounded-xl text-sm font-bold transition-colors"
                  >
                    Back
                  </button>
                )}
                <button
                  onClick={handleVerify}
                  disabled={code.length !== 6 || isVerifying}
                  className="flex-1 py-3 bg-teal-600 hover:bg-teal-700 text-white rounded-xl text-sm font-bold transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center shadow-sm"
                >
                  {isVerifying ? (
                    <span className="flex items-center">
                      <svg className="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                        <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                        <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                      </svg>
                      Verifying...
                    </span>
                  ) : "Verify"}
                </button>
              </div>
            </div>
          )}

          {step === 'success' && (
            <div className="text-center py-6 animate-in fade-in zoom-in-95">
              <div className="w-16 h-16 rounded-full bg-green-100 text-green-500 flex items-center justify-center mx-auto mb-4">
                <CheckCircle2 className="w-8 h-8" />
              </div>
              <h3 className="text-xl font-black text-slate-800">
                {mode === 'enable' ? '2FA Enabled!' : '2FA Disabled'}
              </h3>
              <p className="text-sm font-medium text-slate-500 mt-2">
                {mode === 'enable' 
                  ? 'Your account is now protected with two-factor authentication.'
                  : 'Two-factor authentication has been removed from your account.'}
              </p>
            </div>
          )}

        </div>
      </div>
    </div>
  );
}
