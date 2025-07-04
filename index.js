const mysql = require('mysql2/promise'); // or require('mysql2').createConnectionPromise
const { program } = require('commander')

program
  .argument('<query>');
program.parse();


async function init(){
  const conn = await mysql.createConnection({
    database: 'mydb',
    user: 'root',
    password: 'RGRW@1906',
    host: '127.0.0.1',
    port: 3306
  })

console.log(await conn.query(`${program.args[0]}`))
console.log('Query executada!')
}

init()