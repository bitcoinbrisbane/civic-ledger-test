module.exports = {
    networks: {
        ganache: {
            host: '127.0.0.1',
            port: 7545,
            network_id: 5777,
            gas: 5000000
        }
    },
    solc: {
      optimizer: {
        enabled: true,
        runs: 500
      }
    }
};
