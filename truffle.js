module.exports = {
    networks: {
        ganache: {
            host: '127.0.0.1',
            port: 7545,
            network_id: 5777,
            gas: 5000000
        },
        rinkeby: {
            host: '127.0.0.1',
            port: 8555,
            network_id: 4,
            gas: 5000000,
            gasPrice: 4000000000,
            from : "0xdef7a10de78d9474daf9d33c09e05bc50391e9f4",
            password : ""
        }
    },
    solc: {
      optimizer: {
        enabled: true,
        runs: 500
      }
    }
};
