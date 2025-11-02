import matplotlib.pyplot as plt
from datetime import datetime
from secrets import token_hex

# Define E over Q (label or coefficients)
E = EllipticCurve('11a1')
# E = EllipticCurve([a1,a2,a3,a4,a6])

p = 101  # example prime

'''
for p in prime_range(10^5):
    if E.has_good_reduction(p):
        t_p = E.ap(p)            # a_p
        print("a_{} = {}".format(p, t_p))
    else:
        # Sage still returns the correct local a_p for bad reduction (0 for additive, ±1 for multiplicative)
        t_p = E.ap(p)
        print("Bad reduction at {}, a_p = {}".format(p, t_p))
'''


# naive function that checks if the length conf_int tail of an array converges to 
# the goal within epsilon. This check is not efficient if conf_int is large: it's O(conf_int) times,
# but you can make it O(1) time. But this will do for now.
def converges(arr, target, conf_int, epsilon):
    if len(arr) < conf_int:
        return False
    else:
        return all(abs(val - target)<epsilon for val in arr[-conf_int:])
    
def dec_form(arr):
    return [round(x,ndigits=5) for x in arr]

def time_to_converge(E_coeff, cont_int, epsilon, wp, log_max):
    E = EllipticCurve(E_coeff)
    goal_rank = rank(E)
    print("rank is", goal_rank)
    sequence_data = []
    fraction_acc = 0
    p_bd = 0
    
    
    start_time = cputime()
        
    for x in range(2, 10^log_max):
        # keep on adding the prime until you're done addind to bound
        if x%100 == 0:
            print("Progress: x=",x)
            print("Tail:", dec_form(sequence_data[-10:]))
        while next_prime(p_bd) <= x:
            #print("working on prime = ",p_bd)
            p_bd = next_prime(p_bd)
            
            multiplier = wp[p_bd%5]
            if multiplier != 0:
                fraction_acc += multiplier*E.ap(p_bd)*log(p_bd)/p_bd
        
        
        # add data entry to the new array
        sequence_data.append(fraction_acc/log(x))
        
        # check convergence 
        if converges(sequence_data, (1/2)-goal_rank, cont_int, epsilon):
            end_time = cputime()
            print("Converged at x=",x)
            return dec_form(sequence_data), x, end_time - start_time
        
    return dec_form(sequence_data),0,0

def plot_helper(filename, title, data_lists, name_list):
    for idx in range(len(data_lists)):
        plt.plot(data_lists[idx], label=name_list[idx])
        
    
    plt.xlabel("x values"); plt.ylabel("sum")
    plt.legend()
    plt.title(title, fontsize=12, loc="center", pad=8) 
    plt.savefig(filename+".png", dpi = 300, bbox_inches="tight")
    
    

def test_wrapper():
    curves_to_test = [[1, -1, 0, -16, 28],[0, -1, 1, -34, 90],[1, 0, 0, -34, 39], [0, 0, 1, -37, 126], [0, 0, 1, -169, 930],[0, 0, 1, -679, 6840]]
    epsilon = 0.25
    log_max = 3
    cont_int = 100
    
    
    wp_trivial = {0:0, 1:1, 2:1, 3:1, 4:1}
    wp_smart_dump2 = {0:0, 1:1, 2:0, 3:2, 4:1}
    wp_smart_dump3 = {0:0, 1:1, 2:2, 3:0, 4:1}
    
    for curve in curves_to_test:
        plt.clf()         
        E = EllipticCurve(curve)
        goal_rank = rank(E)
        print("Curve is given by",curve)
        print("Original Mestre-Nagao")
        original_data, original_x, original_time = time_to_converge(curve, cont_int, epsilon, wp_trivial, log_max)
        print("")
    
        print("Smart Mestre-Nagao: dump 2")
        smart_data_2, smart_x_2, smart_time_2 = time_to_converge(curve, cont_int, epsilon, wp_smart_dump2, log_max)
        print("")
    
        print("Smart Mestre-Nagao: dump 3")
        smart_data_3, smart_x_3, smart_time_3 = time_to_converge(curve, cont_int, epsilon, wp_smart_dump3, log_max)
        
        print("")
        print("")
        print("")
        print("Curve:", curve)
        print("rank is ", rank(EllipticCurve(curve)))
        print("")
        print("Original took ", original_time, " s")
        print("converged at x = ", original_x)
        #print(original_data)
    
        
        print("Smart dump 2 took ", smart_time_2, " s")
        print("converged at x = ", smart_x_2)
        #print(smart_data_2)
        
        
        print("Smart dump 3 took ", smart_time_3, " s")
        print("converged at x = ", smart_x_3)
        #print(smart_data_3)
        
        fname = f"plot-{datetime.now().strftime('%Y%m%d-%H%M%S')}-{token_hex(4)}.png" 
        
        data_list = [original_data, smart_data_2, smart_data_3]
        name_list = ['Original', 'dump 2', 'dump 3']
        
        title = f"Elliptic curve given by ({', '.join(map(str, curve))}) with rank {goal_rank}"
        
        plot_helper(fname, title, data_list, name_list)
        
        print("-----------------------------------------------------------------------------------------------------------")
test_wrapper()




'''

Next step: plot the data and see what happens.

'''


