from brownie import accounts, Lottery, network, config
from scripts.helpful_scripts import get_account, get_pf_address, LOCAL_BLOCKCHAIN_NETWORKS
import random
import time


def deploy_lottery():
    Owner = get_account()
    pf_address = get_pf_address()

    print('Deploying Lottery...')
    lottery = Lottery.deploy(pf_address,
                             {'from': Owner},
                             publish_source=config['networks'][network.show_active()].get('verify'))

    time.sleep(1)

    print('Deployed!')
    print('Getting entrance fee and ticket cost...')
    entranceFee, ticketCost = lottery.getEntranceFee()

    if network.show_active() in LOCAL_BLOCKCHAIN_NETWORKS:
        entranceFee, ticketCost = entranceFee * 10**10, ticketCost * 10**10

    print(f'Entrance Fee: {entranceFee}, Ticket Cost: {ticketCost}')

    print('Done!')

    participant1 = accounts[1]
    participant2 = accounts[2]

    #entranceFee = '0.0' + str(entranceFee)[0]
    #entranceFee = web3.toWei(float(entranceFee), 'ether')

    #ticketCost = '0.00' + str(ticketCost)[0]
    #ticketCost = web3.toWei(float(ticketCost), 'ether')

    print('Entering -> Participant 1.')
    print('The cost for entering is 50$')
    to_enter = input(
        'Would you like to enter the lottery? Type [y] for yes and [n] for no.  ')
    if to_enter == 'y':
        entry_p1 = lottery.enter(
            {'from': participant1, 'value': entranceFee})
        print('Participant 1 entered.')
        print(f'Thank you for Entering {participant1}!')

        time.sleep(1)

        print('The cost of 1 ticket is 2$')
        num_tickets = int(input(
            'How many tickets do you want? you have 1 ticket right now.  '))
        value = ticketCost*num_tickets

        print('Participant 1 getting ticket.')
        lottery.getTickets(num_tickets, {'from': participant1, 'value': value})

        time.sleep(1)

    print('Entering -> Participant 2.')
    print('The cost for entering is 50$')
    to_enter = input(
        'Would you like to enter the lottery? Type [y] for yes and [n] for no.  ')
    if to_enter == 'y':
        entry_p1 = lottery.enter(
            {'from': participant2, 'value': entranceFee})
        print('Participant 2 entered.')
        print(f'Thank you for Entering {participant2}!')

        time.sleep(1)

        print('The cost of 1 ticket is 2$')
        num_tickets = int(input(
            'How many tickets do you want? you have 1 ticket right now.  '))
        value = ticketCost*num_tickets

        print('Participant 2 getting ticket.')
        lottery.getTickets(num_tickets, {'from': participant2, 'value': value})

        time.sleep(1)

    print('All tickets Gotten!')

    print('Ending Lottery...')
    tickets = lottery.getWinner()
    print('Lottery ended!')

    time.sleep(1)

    get_Winner(tickets, lottery, Owner, participant1, participant2)


def get_Winner(tickets, lottery, Owner, part1, part2):
    print('Winner is... ', end='')
    winner = random.choice(tickets)
    if winner == part1.address:
        print('Participant 1!')
        winner = part1
    elif winner == part2.address:
        print('Participant 2!')
        winner = part2
    else:
        winner = Owner
        print('Owner!')

    print(f'The funds of the winner currently: {winner.balance()}')
    lottery.split_funds(winner, {'from': Owner})

    time.sleep(1)

    print('The funds have been sent to the Winner! Enjoy!')
    print(f'The balance of the winner now is: {winner.balance()}')


def main():
    deploy_lottery()
