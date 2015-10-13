[GlobalParams]
  # This is the sliding velocity of the bearing.
  # For example if vel_surface = '44.707 0 0',
  # the surface below the film is moving
  # at 44.707 m/s under the film in the positive
  # x-direction.  
  #
  # Keep it in the x-y plane!
  # And for now, keep it on the x-axis.
  # A TODO list is to fix this problem.
  # Watch out! sliding velocity gives the problem
  # hyperbolic characteristics, and potential 
  # instability.  
  #
  # Note: you must change this in Kernels/pressure
  # below to match the x component of vel_surface.

  vel_surface = '0 0 0'
[]

[Mesh]
  type = FileMesh
  file = ../filmMesh.unv
  uniform_refine = 0
[]

[Variables]
  [./p]
    order = FIRST
    family = LAGRANGE
    [./InitialCondition]
      type = ConstantIC
      value = 100.0
    [../]
  [../]
[]

[AuxVariables]
  active = 'h m_dot_y m_dot_x sigma_zx sigma_zy'
  [./h]
    order = FIRST
    family = LAGRANGE
  [../]
  [./vel_x]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./vel_y]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./m_dot_x]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./m_dot_y]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./sigma_zx]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./sigma_zy]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[Kernels]
  [./Pressure]
    type = CompressibleReynoldsPressure
    variable = p
    h = h
    v = 0 # Make sure this matches the x component of
          # vel surface.
  [../]
[]

[AuxKernels]
  active = 'sigma_zx sigma_zy h m_dot_y m_dot_x'
  [./h]
    type = AlphaBetaH
    variable = h
    alpha = 0
    beta = 8.73e-4 # ~ 0.05 deg
    h = 1e-3
    execute_on = initial
  [../]
  [./vel_x]
    type = ReynoldsMeanVelocity
    variable = vel_x
    component = 0
    p = p
    h = h
  [../]
  [./vel_y]
    type = ReynoldsMeanVelocity
    variable = vel_y
    component = 1
    p = p
    h = h
  [../]
  [./m_dot_x]
    type = ReynoldsMassFlow
    variable = m_dot_x
    component = 0
    p = p
    h = h
  [../]
  [./m_dot_y]
    type = ReynoldsMassFlow
    variable = m_dot_y
    component = 1
    p = p
    h = h
  [../]
  [./sigma_zx]
    type = ReynoldsShearStress
    variable = sigma_zx
    component = 0
    p = p
    h = h
  [../]
  [./sigma_zy]
    type = ReynoldsShearStress
    variable = sigma_zy
    component = 1
    p = p
    h = h
  [../]
[]

[Postprocessors]
  [./F_z_p]
    type = ElementIntegralVariablePostprocessor
    variable = p
  [../]
  [./massFlow]
    type = ReynoldsMassFlowIntegral
    cross_film_m_dot_x = m_dot_x
    cross_film_m_dot_y = m_dot_y
    boundary = 'top bottom left right'
  [../]
  [./Mx_p]
    type = PressureMomentPointDirection
    pressure = p
    normal = '0 0 1'
    axis = '1 0 0'
    point = '0 0 0'
  [../]
  [./My_p]
    type = PressureMomentPointDirection
    pressure = p
    normal = '0 0 1'
    axis = '0 1 0'
    point = '0 0 0'
  [../]
  [./Mx_shear]
    type = ReynoldsShearMoment
    sigma_zx = sigma_zx
    sigma_zy = sigma_zy
    point = '0 0 0'
    axis = '1 0 0'
  [../]
  [./My_shear]
    type = ReynoldsShearMoment
    sigma_zx = sigma_zx
    sigma_zy = sigma_zy
    point = '0 0 0'
    axis = '0 1 0'
  [../]
  [./Mz_shear]
    type = ReynoldsShearMoment
    sigma_zx = sigma_zx
    sigma_zy = sigma_zy
    point = '0 0 0'
    axis = '0 0 1'
  [../]
  [./F_x_s]
    type = ElementIntegralVariablePostprocessor
    variable = sigma_zx
  [../]
  [./F_y_s]
    type = ElementIntegralVariablePostprocessor
    variable = sigma_zy
  [../]
[]

[BCs]
  [./perimeter]
    type = DirichletBC
    variable = p
    boundary = 'left right top bottom'
    value = 100
  [../]
  [./trailingEdge]
    type = DirichletBC
    variable = p
    value = 100e2
    boundary = inlet
  [../]
[]

[Materials]
  [./air]
    type = ReynoldsIdealGas
    block = 0
    temp = 300 # K
    p = p
  [../]
[]

[Executioner]
  # Preconditioned JFNK (default)
  # nl_rel_tol = 1e-12
  type = Steady
  l_max_its = 25
  nl_max_its = 100
  nl_rel_step_tol = 1e-4
  l_tol = 1e-15
[]

[Outputs]
  [./console]
    type = Console
    perf_log = true
    perf_header = true
  [../]
  [./exodus]
    type = Exodus
    execute_on = 'initial nonlinear failed'
    elemental_as_nodal = true
  [../]
[]

