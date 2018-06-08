Eth
================

This is an example of Ruby on Rails application for working with Ethereum

Ruby on Rails
-------------

This application requires:

- Ruby 2.5.1
- Rails 5.2.0

Learn more about [Installing Rails](http://railsapps.github.io/installing-rails.html).

Getting Started
---------------

### Step 1: Download Geth

First, download the latest geth (1.6.1) to your laptop. <https://geth.ethereum.org/downloads/>

Unknown whether Parity works as well. It will probably take some finagling to work with the Geth-style Genesis block.

### Step 2: Install Rinkeby

Use `Archive node` synchronization section by this link https://www.rinkeby.io/#geth. The synchronization could take about 1 hour on 100mb/s, i5 CPU and 8GB RAM. In this time Ethereum full node takes about 11GB disc space. 

For running console use ` geth --datadir=$HOME/.rinkeby attach ipc:$HOME/.rinkeby/geth.ipc console`. Check sync: `> eth.syncing`  

```
{
  currentBlock: 2417463,
  highestBlock: 2419621,
  knownStates: 0,
  pulledStates: 0,
  startingBlock: 2417401
}
```

or

**false** when sync is done



### Step 3: Clone and configure the Rails app

Clone the app `git clone git@github.com:sunchess/eth.git`

Set your DB credentials in `config/database.yml` file and path to geth.ipc socket in `config/secrets.yml`, section `eth_ipc_path`. In my case this is a "/Users/dmitrievaleksandr/.rinkeby/geth.ipc" string.

Run `bundle install`, `rake db:create db:migrate`, `yarn install` , `rails server` and got to http://localhost:3000



### Step 4: Get test Ethereum

Go to https://www.rinkeby.io/#faucet and make post with your Ethereum address via Tweeter or what you prefer :)

## Development

Any help or feedback is greatly appreciated! From getting knee-deep into elliptic-curve acrobatics, to cleaning up high-level naming conventions, there is something for everyone to do. Even if you are completely lost, just pointing out what is unclear helps a lot!

If you are curious or like to participate in development, drop by #bitcoin-ruby on irc.freenode.net!

## License

The app is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

