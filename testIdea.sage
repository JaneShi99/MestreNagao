import matplotlib.pyplot as plt
import matplotlib as mpl
import numpy as np
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


# turns out this is very time consuming (in a bad way)
def converges(arr, target, conf_int, epsilon):
    if len(arr) < conf_int:
        return False
    else:
        return all(abs(val - target)<epsilon for val in arr[-conf_int:])
    
def dec_form(arr):
    return [round(x,ndigits=5) for x in arr]

def time_to_converge(E_coeff, cont_int, epsilon, wp, upper_bound):
    E = EllipticCurve(E_coeff)
    goal_rank = rank(E)
    print("rank is", goal_rank)
    sequence_data = []
    fraction_acc = 0
    p_bd = 0
    
    
    start_time = cputime()
        
    for x in range(2, upper_bound):
        # keep on adding the prime until you're done addind to bound
        if x%1000 == 0:
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
        '''
        if converges(sequence_data, (1/2)-goal_rank, cont_int, epsilon):
            end_time = cputime()
            print("Converged at x=",x)
            return dec_form(sequence_data), x, end_time - start_time
        '''
        end_time = cputime()
        
    return sequence_data, end_time - start_time


def plot_helper(filename, title, data_lists, name_list):
    step_plot = 100
    
    for idx in range(len(data_lists)):
        x_coords = list(range(len(data_lists[idx])))[::step_plot]
        plt.plot(x_coords, data_lists[idx][::step_plot], label=name_list[idx])
        
    
    plt.xlabel("x values"); plt.ylabel("sum")
    plt.legend()
    plt.title(title, fontsize=12, loc="center", pad=8) 
    plt.savefig(filename, dpi = 300, bbox_inches="tight")



'''
# one-time speed knobs (can also set globally in your script)
mpl.rcParams["path.simplify"] = True
mpl.rcParams["path.simplify_threshold"] = 0.6
mpl.rcParams["agg.path.chunksize"] = 10000

def plot_helper(filename, title, data_lists, name_list, *, max_points=1500, dpi=200):
    fig, ax = plt.subplots(figsize=(7, 4))
    for y, name in zip(data_lists, name_list):
        y = np.asarray(y, dtype=float)

        # optional downsampling to ~screen/figure resolution
        if max_points is not None and y.size > max_points:
            step = max(1, y.size // max_points)
            y = y[::step]

        ax.plot(y, label=name, marker=None, antialiased=False, linewidth=1.0)

    ax.set_xlabel("x values"); ax.set_ylabel("sum")
    ax.legend()
    ax.set_title(title, fontsize=12, loc="center", pad=8)

    # note: bbox_inches="tight" can be slower; drop it if you don't need tight cropping
    fig.savefig(filename, dpi=dpi, bbox_inches="tight")
    plt.close(fig)  # free memory and avoid piling plots if called repeatedly
'''
    

def test_wrapper():
    curves_to_test = [[1, -1, 0, -16, 28],[0, -1, 1, -34, 90],[1, 0, 0, -34, 39], [0, 0, 1, -37, 126], [0, 0, 1, -169, 930],[0, 0, 1, -679, 6840]]
    epsilon = 0.25
    upper_bound = 20000
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
        original_data, original_time = time_to_converge(curve, cont_int, epsilon, wp_trivial, upper_bound)
        print("")
    
        print("Smart Mestre-Nagao: dump 2")
        smart_data_2, smart_time_2 = time_to_converge(curve, cont_int, epsilon, wp_smart_dump2, upper_bound)
        print("")
    
        print("Smart Mestre-Nagao: dump 3")
        smart_data_3, smart_time_3 = time_to_converge(curve, cont_int, epsilon, wp_smart_dump3, upper_bound)
        
        '''
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
        '''
        
        fname = f"plot-{datetime.now().strftime('%Y%m%d-%H%M%S')}.png" 
        
        data_list = [original_data, smart_data_2, smart_data_3]
        name_list = ['Original', 'dump 2', 'dump 3']
        
        title = f"Elliptic curve given by ({', '.join(map(str, curve))}) with rank {goal_rank}"
        
        plot_helper(fname, title, data_list, name_list)
        
        print("-----------------------------------------------------------------------------------------------------------")
        
test_wrapper()




'''

Next step: plot the data and see what happens.

'''


