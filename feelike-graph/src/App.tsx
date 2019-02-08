import React, { Component } from 'react';
import logo from './logo.svg';
import './App.css';
import { LineChart } from "./components";

class App extends Component {
  render() {
    return (
      <div className="App">
        <header className="App-header">
          <LineChart/>
        </header>
      </div>
    );
  }
}

export default App;
