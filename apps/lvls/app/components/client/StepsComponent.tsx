import React from "react";
import { motion } from "framer-motion";

interface StepProps {
  step: number;
  currentStep: number;
}

const Step: React.FC<StepProps> = ({ step, currentStep }) => {
  const status =
    currentStep === step
      ? "active"
      : currentStep < step
      ? "inactive"
      : "complete";

  return (
    <motion.div animate={status} className="relative w-10 h-10">
      <motion.div
        variants={{
          active: {
            scale: 1,
            transition: {
              delay: 0,
              duration: 0.2
            }
          },
          complete: {
            scale: 1.25
          }
        }}
        transition={{
          duration: 0.6,
          delay: 0.2,
          type: "tween",
          ease: "circOut"
        }}
        className="absolute inset-0 rounded bg-blue-200"
      />

      <motion.div
        initial={false}
        variants={{
          inactive: {
            backgroundColor: "#fff", // neutral
            borderColor: "#e5e5e5", // neutral-200
            color: "#000" // black
          },
          active: {
            backgroundColor: "#fff",
            borderColor: "#3b82f6", // blue-500
            color: "#3b82f6" // blue-500
          },
          complete: {
            backgroundColor: "#3b82f6", // blue-500
            borderColor: "#3b82f6", // blue-500
            color: "#fff" // neutral-400
          }
        }}
        transition={{ duration: 0.2 }}
        className="relative flex items-center justify-center w-10 h-10 border-2 font-semibold"
      >
        <div className="flex items-center justify-center">
          <span>{step}</span>
        </div>
      </motion.div>
    </motion.div>
  );
};

export default Step;
