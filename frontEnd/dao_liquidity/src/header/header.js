import Container from 'react-bootstrap/Container';
import Navbar from 'react-bootstrap/Navbar';
import Button from 'react-bootstrap/Button';
import './header.css';

function Header() {
  return (
    <Navbar>
        <Container>
            <Navbar.Brand href="#home">Dao Owned Liquidity</Navbar.Brand>
            <Navbar.Toggle />
            <Navbar.Collapse className="justify-content-end">
                <Button variant="primary">Connect Wallet</Button>{' '}
            </Navbar.Collapse>
        </Container>
    </Navbar>
  );
}

export default Header;