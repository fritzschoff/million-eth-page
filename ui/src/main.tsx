import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import '@fontsource/roboto/400.css';
import '@fontsource/roboto/700.css';
import { createTheme, ThemeProvider } from '@mui/material/styles';
import { yellow } from '@mui/material/colors';
import { CssBaseline } from '@mui/material';
import Layout from './components/Layout';

const theme = createTheme({
  components: {
    MuiLink: {
      defaultProps: {
        underline: 'none',
      },
    },
    MuiTextField: {
      styleOverrides: {
        root: {
          '& .MuiOutlinedInput-notchedOutline': {
            borderColor: '#FFFFFF',
          },
          '& .MuiInputLabel-root': {
            color: '#FFFFFF',
          },
          '& .MuiInputBase-input::placeholder': {
            color: '#FFFFFF',
          },
        },
      },
    },
    MuiButton: {
      styleOverrides: {
        root: {
          '&.Mui-disabled': {
            backgroundColor: yellow[600],
          },
        },
      },
    },
  },
  palette: {
    primary: yellow,
    background: {
      default: '#000000',
    },
    text: {
      primary: '#FFFFFF',
    },
  },
});

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<Layout />}>
            <Route path="*" element={<div>404 - Page Not Found</div>} />
          </Route>
        </Routes>
      </BrowserRouter>
    </ThemeProvider>
  </StrictMode>
);
