"""
eco_advisor.py - Valorant round-by-round economy advisor.

Enter each player's credits and your current loss streak. It tells you
whether to full buy, full buy with drops, or save, and projects
everyone's credits next round if you win or lose.
"""

# --- Game constants (update here if a patch changes them) ---
TEAM_SIZE = 5
CREDIT_CAP = 9000
WIN_BONUS = 3000
LOSS_BONUS = [1900, 2400, 2900]   # 1st, 2nd, 3rd+ consecutive loss
FULL_BUY = 3900                   # Vandal/Phantom + heavy shield


def loss_bonus(streak):
    """Credits a player gets for losing with this many losses in a row."""
    if streak <= 0:
        return 0
    return LOSS_BONUS[min(streak, len(LOSS_BONUS)) - 1]


def ask_int(prompt, low, high):
    """Keep asking until we get a whole number in [low, high]."""
    while True:
        try:
            value = int(input(prompt))
        except ValueError:
            print("  numbers only, try again")
            continue
        if low <= value <= high:
            return value
        print(f"  needs to be between {low} and {high}")


def get_team_credits():
    return [ask_int(f"  Player {i} credits: ", 0, CREDIT_CAP)
            for i in range(1, TEAM_SIZE + 1)]


def project(credits, income):
    """Credits next round if nobody spends anything (i.e. we save)."""
    return [min(c + income, CREDIT_CAP) for c in credits]


def full_buy_gap(credits):
    """Return (credits short of a full buy, spare credits that could be dropped)."""
    deficit = sum(max(0, FULL_BUY - c) for c in credits)
    surplus = sum(max(0, c - FULL_BUY) for c in credits)
    return deficit, surplus


def decide(credits, streak):
    """Return (call, reason) for this round."""
    deficit, surplus = full_buy_gap(credits)
    if deficit == 0:
        return "FULL BUY", "everyone can afford a rifle + heavy shield."
    if deficit <= surplus:
        return "FULL BUY (WITH DROPS)", f"richer players can cover the {deficit}-credit gap."

    # Can't full buy now. Would saving set up a full buy even if we lose?
    lose_next = project(credits, loss_bonus(streak + 1))
    lose_deficit, lose_surplus = full_buy_gap(lose_next)
    if lose_deficit <= lose_surplus:
        return "SAVE", "even if you lose, next round is a full buy."

    return "SAVE", "can't afford a full buy and saving won't get you there either, so bank the loss bonus."

#returns an object enumerate
def print_projection(credits, streak):
    win_next = project(credits, WIN_BONUS)
    lose_next = project(credits, loss_bonus(streak + 1))
    print("\n  Player |  Now | If win | If lose")
    print("  -------+------+--------+--------")
    for i, (now, w, l) in enumerate(zip(credits, win_next, lose_next), start=1):
        print(f"     {i}   | {now:>4} | {w:>6} | {l:>6}")


def main():
    print("=== VALORANT ECO ADVISOR ===")
    history = []          # list of (round_number, call)
    tally = {}            # call -> how many times
    round_num = 1

    while True:
        print(f"\n--- Round {round_num} ---")
        credits = get_team_credits()
        streak = ask_int("  Current loss streak (0 if you just won): ", 0, 20)

        call, reason = decide(credits, streak)
        print(f"\n  CALL: {call}")
        print(f"  Why:  {reason}")
        print_projection(credits, streak)

        history.append((round_num, call))
        tally[call] = tally.get(call, 0) + 1
        round_num += 1

        again = input("\nAnother round? (y/n): ").strip().lower()
        if again != "y":
            break

    #join, returns a new string 
    print("\n=== SESSION SUMMARY ===")
    for rnd, call in history:
        print(f"  Round {rnd}: {call}")
    print("\n  Totals:", ", ".join(f"{c} x{n}" for c, n in tally.items()))


if __name__ == "__main__":
    main()