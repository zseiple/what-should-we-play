import React, { Component } from 'react';
import { Route, Routes } from 'react-router-dom';
import { Layout } from './components/Layout';
import { Home } from './components/Home';
import { CommonGames } from './components/commongames/CommonGames';

import './custom.css'

export default class App extends Component {
  static displayName = App.name;

  render () {
    return (
        <Layout>
        <Routes>
        <Route exact path='/' element={<Home />} />
        <Route path="/games" element={<CommonGames/>} />
        </Routes>
      </Layout>
    );
  }
}
