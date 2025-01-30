import Header from './Header';
import Footer from './Footer';
import { Outlet } from 'react-router-dom';
import { Container } from '@mui/material';

export default function Layout() {
  return (
    <Container maxWidth="lg">
      <Header />
      <Outlet />
      <Footer />
    </Container>
  );
}
