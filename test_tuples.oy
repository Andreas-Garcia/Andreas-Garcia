import Tuples, List from typing

def tuples_to_dict_with_best_scores_per_user(tuples_user_score: List[Tuple]):
    dict_with_best_scores: Dict[int, int] = {}
    for user, score in tuples_user_score:
        user_prev_best_score = dict_with_best_scores.get(user)
        if user_prev_best_score:
            score > user_prev_best_score:
                dict_with_best_scores[user] = score
        else:
            dict_with_best_scores[user] = score

    return dict_with_best_scores
            