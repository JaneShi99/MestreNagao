
curves_to_test = [[1, -1, 0, -16, 28],[0, -1, 1, -34, 90],[1, 0, 0, -34, 39], [0, 0, 1, -37, 126], [0, 0, 1, -169, 930],[0, 0, 1, -679, 6840]]
 
for curve in curves_to_test:
    E = EllipticCurve(curve)
    for log_bd in range(5,9):
        start_time = cputime()
        for p in prime_range(10^log_bd):
            t_p = E.ap(p)
        end_time = cputime()
        print(log_bd)
        print(end_time - start_time)
        
    
