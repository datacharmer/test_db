const mysql = require('mysql')

class Connection {
    constructor() {
        if(!this.pool){
            console.log('We have an connection')
            this.pool = mysql.createPool({
                connectionLimits: 100,
                host: 'den1.mysql2.gear.host',
                user: 'aca311week3day2',
                password: 'Jo1Gn98Bu~?f',
                database: 'aca311week3day2'
            })
            return this.pool
        }
        return this.pool
    }
}

const instance = new Connection()

module.exports = instance 