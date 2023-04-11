/** @type {import('tailwindcss').Config} */
// eslint-disable-next-line @typescript-eslint/no-var-requires
const flattenColorPalette = require('tailwindcss/lib/util/flattenColorPalette').default;
// eslint-disable-next-line @typescript-eslint/no-var-requires
const plugin = require('tailwindcss/plugin');

const addVariablesForCSSColors = ({ addBase, theme }) => {
      const allColors = flattenColorPalette(theme("colors"));
      const newCssVars = Object.fromEntries(
        Object.entries(allColors).map(([key, val]) => [`--${key}`, val])
      );

      addBase({
        ":root": newCssVars,
      });
}

module.exports = {
  content: [
    "./app/**/*.{js,ts,jsx,tsx}", // <-- Add this line
    "./src/**/*.{js,jsx,ts,tsx}",
  ],


  theme: {
    extend: {
      fontFamily: {
        noka: ["noka", "sans-serif"],
        forma: ["forma-djr-text", "sans-serif"],
      },
      spacing: {
        34: 8.5 + "rem"
      },
      animation: {
            'pulse-bg': 'pulse-bg 20s infinite'
      },
      keyframes: (theme) => ({
        'pulse-bg': {
                '0%': { backgroundColor: 'var(--tw-gradient-from)' },
                '50%': { backgroundColor: 'var(--tw-gradient-to)' },
                '100%': { backgroundColor: 'var(--tw-gradient-from)' },
        },
        rerender: {
          "0%": {
            'border-color': theme('colors.red.500'),
          },
          "40%": {
            'border-color': theme('colors.red.500'),
          }
        },
        shimmer: {
              "100%": {
                "transform": "translateX(100%)",
              },
        },
        highlight: {
          '0%': {
            background: theme('colors.red.500'),
            color: theme('colors.white'),
          },
          '40%': {
            background: theme('colors.red.500'),
            color: theme('colors.white'),
          },
        },
      }),
    },
  },
  plugins: [ addVariablesForCSSColors,
    plugin(function({ addUtilities }) {
      addUtilities({
    /* Hide scrollbar for Chrome, Safari and Opera */
    ".no-scrollbar::-webkit-scrollbar": {
      'display': 'none'
    },
    ".always-scroll::-webkit-scrollbar": {
     '-webkit-appearance': 'none',
      'width': '7px'
    },
    ".always-scroll-thumb::-webkit-scrollbar-thumb": {
      'border-radius': '4px',
      'background-color': 'rgba(0, 0, 0, .5)',
      'box-shadow': '0 0 1px rgba(255, 255, 255, .5)'
    },
    /* Hide scrollbar for IE, Edge and Firefox */
    ".no-scrollbar": {
      '-ms-overflow-style': 'none',  /* IE and Edge */
      'scrollbar-width': 'none'  /* Firefox */
      },
    '.no-spinner-outer::-webkit-outer-spin-button': {
        '-webkit-appearance': 'none',
        'margin': '0',
        '-moz-appearance': 'textfield !important'
      },
    '.no-spinner-inner::-webkit-inner-spin-button': {
        '-webkit-appearance': 'none',
        'margin': '0',
        '-moz-appearance': 'textfield !important'
      }
     
      })
    })
  ],
}
