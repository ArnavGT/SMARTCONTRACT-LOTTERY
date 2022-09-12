from brownie import Lottery, accounts, config, network, web3
from scripts.helpful_scripts import get_account, get_pf_address
import random


def test_fees():
    Owner = get_account()
    pf_address = get_pf_address()

    lottery = Lottery.deploy(pf_address,
                             {'from': Owner},
                             publish_source=config['networks'][network.show_active()].get('verify'))

    ticketCost, entranceFee = lottery.getEntranceFee()

    entranceFee = a = (entranceFee*(10**10)/(10**18))*1672
    ticketCost = (ticketCost*(10**10)/(10**18))*1672
    entranceFee = ticketCost
    ticketCost = a

    assert entranceFee >= 49
    print(entranceFee)

    assert ticketCost >= 1.5
    print(ticketCost)
