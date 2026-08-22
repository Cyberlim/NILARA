"use client";

import { X } from "lucide-react";
import { useEffect } from "react";

export default function ImageModal({ isOpen, onClose, imageSrc, altText = "Image", children }) {
  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
    } else {
      document.body.style.overflow = 'unset';
    }
    return () => { document.body.style.overflow = 'unset'; };
  }, [isOpen]);

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-[200] flex items-center justify-center p-4">
      {/* Backdrop */}
      <div 
        className="absolute inset-0 bg-black/80 backdrop-blur-sm transition-opacity cursor-pointer"
        onClick={onClose}
      ></div>

      {/* Modal Container */}
      <div 
        className="relative z-10 max-w-4xl max-h-[90vh] w-full flex flex-col items-center justify-center animate-in zoom-in-95 duration-200"
        onClick={(e) => e.stopPropagation()}
      >
        <button 
          onClick={onClose}
          className="absolute -top-12 right-0 sm:-right-12 sm:top-0 w-10 h-10 flex items-center justify-center rounded-full bg-white/10 hover:bg-white/20 text-white transition-colors"
        >
          <X className="w-5 h-5" />
        </button>
        
        {imageSrc ? (
          <img 
            src={imageSrc} 
            alt={altText} 
            className="max-w-full max-h-[85vh] object-contain rounded-2xl shadow-2xl bg-white"
          />
        ) : (
          <div className="transform scale-[3] sm:scale-[4] origin-center shadow-2xl rounded-2xl bg-white p-4">
            {children}
          </div>
        )}
      </div>
    </div>
  );
}
