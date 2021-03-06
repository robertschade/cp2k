!--------------------------------------------------------------------------------------------------!
!   CP2K: A general program to perform molecular dynamics simulations                              !
!   Copyright (C) 2000 - 2019  CP2K developers group                                               !
!--------------------------------------------------------------------------------------------------!

!     **************************************************************************************************
!     > \brief Interface to the SIRIUS Library
!     > \par History
!     >      07.2018 initial create
!     > \author JHU
!     **************************************************************************************************
      MODULE sirius_interface
#if defined(__SIRIUS)
         USE sirius, ONLY: &
            string, bool, sirius_initialize, sirius_finalize, sirius_create_context, sirius_import_parameters, &
            sirius_create_ground_state, sirius_initialize_context, sirius_set_mpi_grid_dims, &
            sirius_set_lattice_vectors, sirius_add_atom_type, sirius_add_atom, sirius_create_kset, &
            sirius_get_energy, sirius_get_forces, sirius_get_stress_tensor, sirius_create_kset_from_grid, &
            sirius_find_ground_state, sirius_update_context, sirius_set_atom_position, sirius_update_ground_state, &
            sirius_set_atom_type_radial_grid, sirius_add_atom_type_radial_function, sirius_set_atom_type_dion, &
            sirius_option_set_string, sirius_option_set_logical, sirius_option_set_double, &
            sirius_option_set_int, sirius_option_get_string, sirius_option_get_logical, &
            sirius_option_get_double, sirius_option_get_int, sirius_option_get_name_and_type, &
            sirius_option_get_length, sirius_dump_runtime_setup, sirius_option_add_string_to, sirius_add_xc_functional
#endif
         USE input_section_types, ONLY: section_vals_val_get, section_vals_get_subs_vals2, section_vals_get, &
            section_vals_duplicate
         USE input_constants, ONLY: do_gapw_log
         USE atom_kind_orbitals, ONLY: gth_potential_conversion, calculate_atomic_orbitals
         USE atomic_kind_types, ONLY: atomic_kind_type, get_atomic_kind
         USE atom_types, ONLY: atom_gthpot_type, release_atom_potential
         USE atom_utils, ONLY: atom_local_potential
         USE atom_upf, ONLY: atom_read_upf, &
            atom_release_upf, &
            atom_upfpot_type
         USE cell_methods, ONLY: read_cell, write_cell
         USE cell_types, ONLY: real_to_scaled, cell_clone, cell_create, &
            cell_release, cell_type
         USE qs_grid_atom, ONLY: grid_atom_type, allocate_grid_atom, &
            deallocate_grid_atom, create_grid_atom
         USE qs_kind_types, ONLY: &
            check_qs_kind_set, get_qs_kind, get_qs_kind_set, init_gapw_basis_set, init_gapw_nlcc, &
            init_qs_kind_set, qs_kind_type, set_qs_kind, write_gto_basis_sets, write_qs_kind_set
         USE qs_subsys_types, ONLY: qs_subsys_get, qs_subsys_retain, &
            qs_subsys_release, qs_subsys_set, qs_subsys_type
         USE cp_para_types, ONLY: cp_para_env_type
         USE cp_subsys_methods, ONLY: cp_subsys_create
         USE cp_subsys_types, ONLY: cp_subsys_release, cp_subsys_set, cp_subsys_type
         USE input_section_types, ONLY: section_vals_get_subs_vals, section_vals_type, section_vals_val_get
         USE particle_types, ONLY: particle_type
         USE external_potential_types, ONLY: &
            all_potential_type, allocate_potential, deallocate_potential, get_potential, &
            gth_potential_type, init_potential, local_potential_type, read_potential, &
            set_default_all_potential, set_potential, sgp_potential_type, write_potential
         USE mathconstants, ONLY: dfac, &
            gamma1, &
            pi, fourpi
         USE pwdft_environment_types, ONLY: pwdft_environment_type, pwdft_energy_type, pwdft_env_set, pwdft_env_get
         USE ISO_C_BINDING, ONLY: &
            C_ASSOCIATED, C_BOOL, C_DOUBLE, C_FUNPTR, C_F_POINTER, C_INT, C_NULL_FUNPTR, C_NULL_PTR, &
            C_PTR, C_CHAR
         USE kinds, ONLY: dp, default_string_length

#include "./base/base_uses.f90"
         IMPLICIT NONE

         PRIVATE

!     *** Global parameters ***

   CHARACTER(len=*), PARAMETER, PRIVATE :: moduleN = 'sirius_interface'

!     *** Public subroutines ***

         PUBLIC :: cp_sirius_init, cp_sirius_finalize
         PUBLIC :: cp_sirius_create_env, cp_sirius_energy_force, cp_sirius_update_context

      CONTAINS

!     **************************************************************************************************
!     > \brief ...
!     > \param
!     > \par History
!     >      07.2018 start the Sirius library
!     > \author JHU
!     **************************************************************************************************
#if defined(__SIRIUS)
! **************************************************************************************************
!> \brief ...
! **************************************************************************************************
         SUBROUTINE cp_sirius_init()

      CHARACTER(len=*), PARAMETER :: routineN = 'cp_sirius_init', routineP = moduleN//':'//routineN

            CALL sirius_initialize(bool(.FALSE.))

         END SUBROUTINE cp_sirius_init
#else
!     **************************************************************************************************
!     > \brief ...
!     **************************************************************************************************
! **************************************************************************************************
!> \brief ...
! **************************************************************************************************
         SUBROUTINE cp_sirius_init()
! Do nothing - Sirius library is missing.
         END SUBROUTINE cp_sirius_init
#endif

!     **************************************************************************************************
!     > \brief ...
!     > \param
!     > \par History
!     >      07.2018 stop the Sirius library
!     > \author JHU
!     **************************************************************************************************
#if defined(__SIRIUS)
! **************************************************************************************************
!> \brief ...
! **************************************************************************************************
         SUBROUTINE cp_sirius_finalize()

      CHARACTER(len=*), PARAMETER :: routineN = 'cp_sirius_finalize', &
         routineP = moduleN//':'//routineN

            CALL sirius_finalize(bool(.FALSE.), bool(.FALSE.), bool(.FALSE.))

         END SUBROUTINE cp_sirius_finalize
#else
!     **************************************************************************************************
!     > \brief ...
!     **************************************************************************************************
! **************************************************************************************************
!> \brief ...
! **************************************************************************************************
         SUBROUTINE cp_sirius_finalize()
!
         END SUBROUTINE cp_sirius_finalize
#endif

!     **************************************************************************************************
!     > \brief ...
!     > \param pwdft_env ...
!     > \param
!     > \par History
!     >      07.2018 Create the Sirius environment
!     > \author JHU
!     **************************************************************************************************
#if defined(__SIRIUS)
! **************************************************************************************************
!> \brief ...
!> \param pwdft_env ...
! **************************************************************************************************
         SUBROUTINE cp_sirius_create_env(pwdft_env)
      TYPE(pwdft_environment_type), POINTER              :: pwdft_env

      CHARACTER(len=*), PARAMETER :: routineN = 'cp_sirius_create_env', &
         routineP = moduleN//':'//routineN

      CHARACTER(len=2)                                   :: element_symbol
      CHARACTER(len=64)                                  :: section_name
      CHARACTER(len=default_string_length)               :: label
      INTEGER                                            :: i, iatom, ibeta, ifun, ikind, iwf, j, l, &
                                                            n, natom, nbeta, nkind, nmesh, &
                                                            num_mag_dims, sirius_mpi_comm
      INTEGER(KIND=C_INT), DIMENSION(3)                  :: k_grid, k_shift
      INTEGER, DIMENSION(:), POINTER                     :: kk
      LOGICAL                                            :: up, use_ref_cell
      LOGICAL(4)                                         :: use_symmetry
      REAL(KIND=C_DOUBLE), ALLOCATABLE, DIMENSION(:)     :: fun
      REAL(KIND=C_DOUBLE), ALLOCATABLE, DIMENSION(:, :)  :: dion
      REAL(KIND=C_DOUBLE), DIMENSION(3)                  :: a1, a2, a3, v1, v2
      REAL(KIND=dp)                                      :: al, angle1, angle2, cval, focc, &
                                                            magnetization, mass, pf, rl, zeff
      REAL(KIND=dp), ALLOCATABLE, DIMENSION(:)           :: beta, corden, ef, fe, locpot, rc, rp
      REAL(KIND=dp), DIMENSION(3)                        :: vr, vs
      REAL(KIND=dp), DIMENSION(:), POINTER               :: density
      REAL(KIND=dp), DIMENSION(:, :), POINTER            :: wavefunction, wfninfo
      TYPE(atom_gthpot_type), POINTER                    :: gth_atompot
      TYPE(atom_upfpot_type), POINTER                    :: upf_pot
      TYPE(atomic_kind_type), DIMENSION(:), POINTER      :: atomic_kind_set
      TYPE(atomic_kind_type), POINTER                    :: atomic_kind
      TYPE(C_PTR)                                        :: gs_handler = C_NULL_PTR, &
                                                            ks_handler = C_NULL_PTR, &
                                                            sctx = C_NULL_PTR
      TYPE(cell_type), POINTER                           :: my_cell, my_cell_ref
      TYPE(cp_para_env_type), POINTER                    :: para_env
      TYPE(grid_atom_type), POINTER                      :: atom_grid
      TYPE(gth_potential_type), POINTER                  :: gth_potential
      TYPE(particle_type), DIMENSION(:), POINTER         :: particle_set
      TYPE(qs_kind_type), DIMENSION(:), POINTER          :: qs_kind_set
      TYPE(qs_subsys_type), POINTER                      :: qs_subsys
      TYPE(section_vals_type), POINTER                   :: libxc_fun, pwdft_section, &
                                                            pwdft_sub_section, xc_fun, xc_section

            CPASSERT(ASSOCIATED(pwdft_env))
! create context of simulation
            CALL pwdft_env_get(pwdft_env, para_env=para_env)
            sirius_mpi_comm = para_env%group
            sctx = sirius_create_context(sirius_mpi_comm)

!     the "fun" starts.

            CALL pwdft_env_get(pwdft_env=pwdft_env, pwdft_input=pwdft_section, xc_input=xc_section)

            ! cp2k should *have* a function that return all xc_functionals. Doing
            ! manually is prone to errors

            IF (ASSOCIATED(xc_section)) THEN
               !     LIBXC is the only repeatable functional section - for each we need
               !     NOT the single values, but the whole section_vals_type independently
               ifun = 0
               DO
                  ifun = ifun+1
                  xc_fun => section_vals_get_subs_vals2(xc_section, i_section=ifun)
                  IF (.NOT. ASSOCIATED(xc_fun)) EXIT
                  IF (TRIM(xc_fun%section%name) == "LIBXC") THEN
                     CALL section_vals_get(xc_fun, n_repetition=n)
                     DO i = 1, n
                        NULLIFY (libxc_fun)
                        CALL section_vals_duplicate(xc_fun, libxc_fun, i_rep_start=i, i_rep_end=i)
                        CALL section_vals_val_get(libxc_fun, "FUNCTIONAL", c_val=section_name)
                        CALL sirius_option_add_string_to(sctx, string('parameters'), string('xc_functionals'), string(section_name))
                     END DO
                  ENDIF
               END DO
            ENDIF

!     import control section
            pwdft_sub_section => section_vals_get_subs_vals(pwdft_section, "control")
            IF (ASSOCIATED(pwdft_sub_section)) THEN
               CALL cp_sirius_feel_in_section(sctx, pwdft_sub_section, string("control"))
            ENDIF

!     import parameters section
            pwdft_sub_section => section_vals_get_subs_vals(pwdft_section, "parameters")
            IF (ASSOCIATED(pwdft_sub_section)) THEN
               CALL cp_sirius_feel_in_section(sctx, pwdft_sub_section, string("parameters"))
               CALL section_vals_val_get(pwdft_sub_section, "ngridk", i_vals=kk)
               k_grid(1) = kk(1)
               k_grid(2) = kk(2)
               k_grid(3) = kk(3)

               CALL section_vals_val_get(pwdft_sub_section, "shiftk", i_vals=kk)
               k_shift(1) = kk(1)
               k_shift(2) = kk(2)
               k_shift(3) = kk(3)
               CALL section_vals_val_get(pwdft_sub_section, "num_mag_dims", i_val=num_mag_dims)
               CALL section_vals_val_get(pwdft_sub_section, "use_symmetry", l_val=use_symmetry)
            ENDIF

!     import mixer section
            pwdft_sub_section => section_vals_get_subs_vals(pwdft_section, "mixer")
            IF (ASSOCIATED(pwdft_sub_section)) THEN
               CALL cp_sirius_feel_in_section(sctx, pwdft_sub_section, string("mixer"))
            ENDIF

            !     import solver section
            pwdft_sub_section => section_vals_get_subs_vals(pwdft_section, "iterative_solver")
            IF (ASSOCIATED(pwdft_sub_section)) THEN
               CALL cp_sirius_feel_in_section(sctx, pwdft_sub_section, string("iterative_solver"))
            ENDIF

            CALL sirius_dump_runtime_setup(sctx, string("runtime.json"))
            CALL sirius_import_parameters(sctx)

! lattice vectors of the unit cell should be in [a.u.] (length is in [a.u.])
            CALL pwdft_env_get(pwdft_env=pwdft_env, qs_subsys=qs_subsys)
            CALL qs_subsys_get(qs_subsys, cell=my_cell, cell_ref=my_cell_ref, use_ref_cell=use_ref_cell)
            a1(:) = my_cell%hmat(:, 1)
            a2(:) = my_cell%hmat(:, 2)
            a3(:) = my_cell%hmat(:, 3)
            CALL sirius_set_lattice_vectors(sctx, a1(1), a2(1), a3(1))

! set up the atomic type definitions
            CALL qs_subsys_get(qs_subsys, &
                               atomic_kind_set=atomic_kind_set, &
                               qs_kind_set=qs_kind_set, &
                               particle_set=particle_set)
            nkind = SIZE(atomic_kind_set)
            DO ikind = 1, nkind
               CALL get_atomic_kind(atomic_kind_set(ikind), &
                                    name=label, element_symbol=element_symbol, mass=mass)
               CALL get_qs_kind(qs_kind_set(ikind), zeff=zeff)
               NULLIFY (upf_pot, gth_potential)
               CALL get_qs_kind(qs_kind_set(ikind), upf_potential=upf_pot, gth_potential=gth_potential)
               IF (ASSOCIATED(upf_pot)) THEN
                  CALL sirius_add_atom_type(sctx, string(label), fname=string(upf_pot%filename), &
                                            mass=REAL(mass, KIND=C_DOUBLE))
               ELSEIF (ASSOCIATED(gth_potential)) THEN
!
                  NULLIFY (atom_grid)
                  CALL allocate_grid_atom(atom_grid)
                  nmesh = 929
                  atom_grid%nr = nmesh
                  CALL create_grid_atom(atom_grid, nmesh, 1, 1, 0, do_gapw_log)
                  ALLOCATE (rp(nmesh), fun(nmesh))
                  IF (atom_grid%rad(1) < atom_grid%rad(nmesh)) THEN
                     up = .TRUE.
                  ELSE
                     up = .FALSE.
                  END IF
                  IF (up) THEN
                     rp(1:nmesh) = atom_grid%rad(1:nmesh)
                  ELSE
                     DO i = 1, nmesh
                        rp(i) = atom_grid%rad(nmesh-i+1)
                     END DO
                  END IF
! add new atom type
                  CALL sirius_add_atom_type(sctx, string(label), &
                                            zn=NINT(zeff+0.001d0), &
                                            mass=REAL(mass, KIND=C_DOUBLE), &
                                            spin_orbit=bool(.FALSE.))
!
                  ALLOCATE (gth_atompot)
                  CALL gth_potential_conversion(gth_potential, gth_atompot)
! set radial grid
                  fun(1:nmesh) = rp(1:nmesh)
                  CALL sirius_set_atom_type_radial_grid(sctx, string(label), nmesh, fun(1))
! set beta-projectors
                  ALLOCATE (ef(nmesh), beta(nmesh))
                  ibeta = 0
                  DO l = 0, 3
                     IF (gth_atompot%nl(l) == 0) CYCLE
                     rl = gth_atompot%rcnl(l)
! we need to multiply by r so that data transfered to sirius are r \beta(r) not beta(r)
                     ef(1:nmesh) = EXP(-0.5_dp*rp(1:nmesh)*rp(1:nmesh)/(rl*rl))
                     DO i = 1, gth_atompot%nl(l)
                        pf = rl**(l+0.5_dp*(4._dp*i-1._dp))
                        j = l+2*i-1
                        pf = SQRT(2._dp)/(pf*SQRT(gamma1(j)))
                        beta(:) = pf*rp**(l+2*i-2)*ef
                        ibeta = ibeta+1
                        fun(1:nmesh) = beta(1:nmesh)*rp(1:nmesh)
                        CALL sirius_add_atom_type_radial_function(sctx, string(label), &
                                                                  string("beta"), fun(1), nmesh, l=l)
                     END DO
                  END DO
                  DEALLOCATE (ef, beta)
                  nbeta = ibeta

! nonlocal PP matrix elements
                  ALLOCATE (dion(nbeta, nbeta))
                  dion = 0.0_dp
                  DO l = 0, 3
                     IF (gth_atompot%nl(l) == 0) CYCLE
                     ibeta = SUM(gth_atompot%nl(0:l-1))+1
                     i = ibeta+gth_atompot%nl(l)-1
                     dion(ibeta:i, ibeta:i) = gth_atompot%hnl(1:gth_atompot%nl(l), 1:gth_atompot%nl(l), l)
                  END DO
                  CALL sirius_set_atom_type_dion(sctx, string(label), nbeta, dion(1, 1))
                  DEALLOCATE (dion)

! set non-linear core correction
                  IF (gth_atompot%nlcc) THEN
                     ALLOCATE (corden(nmesh), fe(nmesh), rc(nmesh))
                     corden(:) = 0.0_dp
                     n = gth_atompot%nexp_nlcc
                     DO i = 1, n
                        al = gth_atompot%alpha_nlcc(i)
                        rc(:) = rp(:)/al
                        fe(:) = EXP(-0.5_dp*rc(:)*rc(:))
                        DO j = 1, gth_atompot%nct_nlcc(i)
                           cval = gth_atompot%cval_nlcc(j, i)
                           corden(:) = corden(:)+fe(:)*rc(:)**(2*j-2)*cval
                        END DO
                     END DO
                     fun(1:nmesh) = corden(1:nmesh)*rp(1:nmesh)
                     CALL sirius_add_atom_type_radial_function(sctx, string(label), string("ps_rho_core"), &
                                                               fun(1), nmesh)
                     DEALLOCATE (corden, fe, rc)
                  END IF

! local potential
                  ALLOCATE (locpot(nmesh))
                  locpot(:) = 0.0_dp
                  CALL atom_local_potential(locpot, gth_atompot, rp)
                  fun(1:nmesh) = locpot(1:nmesh)
                  CALL sirius_add_atom_type_radial_function(sctx, string(label), string("vloc"), &
                                                            fun(1), nmesh)
                  DEALLOCATE (locpot)
!
                  NULLIFY (density, wavefunction, wfninfo)
                  CALL calculate_atomic_orbitals(atomic_kind_set(ikind), qs_kind_set(ikind), &
                                                 density=density, wavefunction=wavefunction, &
                                                 wfninfo=wfninfo, agrid=atom_grid)

! set the atomic radial functions
                  DO iwf = 1, SIZE(wavefunction, 2)
                     focc = wfninfo(1, iwf)
                     l = NINT(wfninfo(2, iwf))
                     IF (up) THEN
                        fun(1:nmesh) = wavefunction(1:nmesh, iwf)*rp(i)
                     ELSE
                        DO i = 1, nmesh
                           fun(i) = wavefunction(nmesh-i+1, iwf)*rp(i)
                        END DO
                     END IF
                     CALL sirius_add_atom_type_radial_function(sctx, &
                                                               string(label), string("ps_atomic_wf"), &
                                                               fun(1), nmesh, l=l, occ=REAL(focc, KIND=C_DOUBLE), n=-1)
                  END DO

! set total charge density of a free atom (to compute initial rho(r))
                  IF (up) THEN
                     fun(1:nmesh) = fourpi*density(1:nmesh)*atom_grid%rad(1:nmesh)**2
                  ELSE
                     DO i = 1, nmesh
                        fun(i) = fourpi*density(nmesh-i+1)*atom_grid%rad(nmesh-i+1)**2
                     END DO
                  END IF
                  CALL sirius_add_atom_type_radial_function(sctx, string(label), string("ps_rho_total"), &
                                                            fun(1), nmesh)

                  IF (ASSOCIATED(density)) DEALLOCATE (density)
                  IF (ASSOCIATED(wavefunction)) DEALLOCATE (wavefunction)
                  IF (ASSOCIATED(wfninfo)) DEALLOCATE (wfninfo)

                  CALL deallocate_grid_atom(atom_grid)
                  DEALLOCATE (rp, fun)
                  DEALLOCATE (gth_atompot)
!
               ELSE
                  CALL cp_abort(__LOCATION__, &
                                'CP2K/SIRIUS: atomic kind needs UPF or GTH potential definition')
               END IF
            END DO

! add atoms to the unit cell
! WARNING: sirius accepts only fractional coordinates;
            natom = SIZE(particle_set)
            DO iatom = 1, natom
               vr(1:3) = particle_set(iatom)%r(1:3)
               CALL real_to_scaled(vs, vr, my_cell)
               atomic_kind => particle_set(iatom)%atomic_kind
               ikind = atomic_kind%kind_number
               CALL get_atomic_kind(atomic_kind, name=label)
               CALL get_qs_kind(qs_kind_set(ikind), zeff=zeff, magnetization=magnetization)
! angle of magnetization might come from input Atom x y z mx my mz
! or as an angle?
! Answer : SIRIUS only accept the magnetization as mx, my, mz
               IF (num_mag_dims .EQ. 3) THEN
                  angle1 = 0.0_dp
                  angle2 = 0.0_dp
                  v1(1) = zeff*magnetization*SIN(angle1)*COS(angle2)
                  v1(2) = zeff*magnetization*SIN(angle1)*SIN(angle2)
                  v1(3) = zeff*magnetization*COS(angle1)
               ELSE
                  v1 = 0._dp
                  v1(3) = zeff*magnetization
               ENDIF
               v2(1:3) = vs(1:3)
               CALL sirius_add_atom(sctx, string(label), v2(1), v1(1))
            ENDDO
! initialize global variables/indices/arrays/etc. of the simulation
            CALL sirius_initialize_context(sctx)

            ! strictly speaking the parameter use_symmetry is initialized at the
            ! beginning but it does no harm to do it that way
            IF (use_symmetry) THEN
               ks_handler = sirius_create_kset_from_grid(sctx, k_grid(1), k_shift(1), use_symmetry=bool(.TRUE.))
            ELSE
               ks_handler = sirius_create_kset_from_grid(sctx, k_grid(1), k_shift(1), use_symmetry=bool(.FALSE.))
            ENDIF
! create ground-state class
            gs_handler = sirius_create_ground_state(ks_handler)

            CALL pwdft_env_set(pwdft_env, sctx=sctx, gs_handler=gs_handler, ks_handler=ks_handler)

         END SUBROUTINE cp_sirius_create_env
#else
!     **************************************************************************************************
!     > \brief ...
!     > \param pwdft_env ...
!     **************************************************************************************************
! **************************************************************************************************
!> \brief ...
!> \param pwdft_env ...
! **************************************************************************************************
         SUBROUTINE cp_sirius_create_env(pwdft_env)
      TYPE(pwdft_environment_type), POINTER              :: pwdft_env

            CPASSERT(ASSOCIATED(pwdft_env))
            CPABORT("Sirius library is missing")
         END SUBROUTINE cp_sirius_create_env
#endif

!     **************************************************************************************************
!     > \brief ...
!     > \param pwdft_env ...
!     > \param
!     > \par History
!     >      07.2018 Update the Sirius environment
!     > \author JHU
!     **************************************************************************************************
#if defined(__SIRIUS)
! **************************************************************************************************
!> \brief ...
!> \param pwdft_env ...
! **************************************************************************************************
         SUBROUTINE cp_sirius_update_context(pwdft_env)
      TYPE(pwdft_environment_type), POINTER              :: pwdft_env

      CHARACTER(len=*), PARAMETER :: routineN = 'cp_sirius_update_context', &
         routineP = moduleN//':'//routineN

      INTEGER                                            :: iatom, natom
      REAL(KIND=C_DOUBLE), DIMENSION(3)                  :: a1, a2, a3, v2
      REAL(KIND=dp), DIMENSION(3)                        :: vr, vs
      TYPE(C_PTR)                                        :: gs_handler = C_NULL_PTR, &
                                                            sctx = C_NULL_PTR
      TYPE(cell_type), POINTER                           :: my_cell
      TYPE(particle_type), DIMENSION(:), POINTER         :: particle_set
      TYPE(qs_subsys_type), POINTER                      :: qs_subsys

            CPASSERT(ASSOCIATED(pwdft_env))
            CALL pwdft_env_get(pwdft_env, sctx=sctx, gs_handler=gs_handler)

! get current positions and lattice vectors
            CALL pwdft_env_get(pwdft_env=pwdft_env, qs_subsys=qs_subsys)

! lattice vectors of the unit cell should be in [a.u.] (length is in [a.u.])
            CALL qs_subsys_get(qs_subsys, cell=my_cell)
            a1(:) = my_cell%hmat(:, 1)
            a2(:) = my_cell%hmat(:, 2)
            a3(:) = my_cell%hmat(:, 3)
            CALL sirius_set_lattice_vectors(sctx, a1(1), a2(1), a3(1))

! new atomic positions
            CALL qs_subsys_get(qs_subsys, particle_set=particle_set)
            natom = SIZE(particle_set)
            DO iatom = 1, natom
               vr(1:3) = particle_set(iatom)%r(1:3)
               CALL real_to_scaled(vs, vr, my_cell)
               v2(1:3) = vs(1:3)
               CALL sirius_set_atom_position(sctx, iatom, v2(1))
            ENDDO

! update ground-state class
            CALL sirius_update_ground_state(gs_handler)

            CALL pwdft_env_set(pwdft_env, sctx=sctx, gs_handler=gs_handler)

         END SUBROUTINE cp_sirius_update_context
#else
!     **************************************************************************************************
!     > \brief ...
!     > \param pwdft_env ...
!     **************************************************************************************************
! **************************************************************************************************
!> \brief ...
!> \param pwdft_env ...
! **************************************************************************************************
         SUBROUTINE cp_sirius_update_context(pwdft_env)
      TYPE(pwdft_environment_type), POINTER              :: pwdft_env

            CPASSERT(ASSOCIATED(pwdft_env))
            CPABORT("Sirius library is missing")
         END SUBROUTINE cp_sirius_update_context
#endif

#if defined(__SIRIUS)
! **************************************************************************************************
!> \brief ...
!> \param sctx ...
!> \param section ...
!> \param section_name ...
! **************************************************************************************************
         SUBROUTINE cp_sirius_feel_in_section(sctx, section, section_name)
      TYPE(C_PTR), INTENT(INOUT)                         :: sctx
      TYPE(section_vals_type), POINTER                   :: section
      CHARACTER(len=1, kind=C_CHAR), DIMENSION(*), &
         INTENT(IN)                                      :: section_name

      CHARACTER(len=256)                                 :: option_name, option_name1
      CHARACTER(len=80)                                  :: str
      CHARACTER(len=80), DIMENSION(:), POINTER           :: tmp
      INTEGER                                            :: ctype, elem, i, ival, j, length, &
                                                            lvalsi(16), number_of_options
      INTEGER, DIMENSION(:), POINTER                     :: ivals
      LOGICAL                                            :: found
      LOGICAL(4)                                         :: lval
      LOGICAL(4), DIMENSION(:), POINTER                  :: lvals
      REAL(kind=dp)                                      :: rval
      REAL(kind=dp), DIMENSION(:), POINTER               :: rvals

            CALL sirius_option_get_length(section_name, number_of_options)

            DO elem = 0, number_of_options-1
               option_name = CHAR(0)
               CALL sirius_option_get_name_and_type(section_name, elem, option_name, ctype)
               option_name1 = TRIM(ADJUSTL(option_name))
               option_name = TRIM(ADJUSTL(option_name))//CHAR(0)
               CALL section_vals_val_get(section, option_name1, explicit=found)
               IF (found) THEN
                  SELECT CASE (ctype)
                  CASE (1)
                     CALL section_vals_val_get(section, option_name1, i_val=ival)
                     CALL sirius_option_set_int(sctx, section_name, option_name, ival, 0)
                  CASE (11)
                     CALL section_vals_val_get(section, option_name1, i_vals=ivals)
                     CALL sirius_option_set_int(sctx, section_name, option_name, ivals(1), SIZE(ivals))
                  CASE (2)
                     CALL section_vals_val_get(section, option_name1, r_val=rval)
                     CALL sirius_option_set_double(sctx, section_name, option_name, rval, 0)
                  CASE (12)
                     CALL section_vals_val_get(section, option_name1, r_vals=rvals)
                     CALL sirius_option_set_double(sctx, section_name, option_name, rvals(1), SIZE(rvals))
                  CASE (3)
                     CALL section_vals_val_get(section, option_name1, l_val=lval)
                     IF (lval) THEN
                        CALL sirius_option_set_logical(sctx, section_name, option_name, 1, 0)
                     ELSE
                        CALL sirius_option_set_logical(sctx, section_name, option_name, 0, 0)
                     ENDIF
                  CASE (13)
                     CALL section_vals_val_get(section, option_name, l_vals=lvals)
                     length = SIZE(lvals)
                     DO i = 1, length
                        IF (lvals(i)) THEN
                           lvalsi(i) = 1
                        ELSE
                           lvalsi(i) = 0
                        ENDIF
                     END DO
                     CALL sirius_option_set_logical(sctx, section_name, option_name, lvalsi(1), length)
                  CASE (4) ! string nightmare
                     CALL section_vals_val_get(section, option_name1, c_val=str)
                     str = TRIM(ADJUSTL(str))//CHAR(0)
                     CALL sirius_option_set_string(sctx, section_name, option_name, string(str))
                  CASE (14)
                     CALL section_vals_val_get(section, option_name1, n_rep_val=length)
                     DO j = 1, length
                        CALL section_vals_val_get(section, option_name1, i_rep_val=j, c_vals=tmp)
                        CALL sirius_option_add_string_to(sctx, section_name, option_name, string(str))
                     END DO
                  CASE DEFAULT
                  END SELECT
               END IF
            END DO
         END SUBROUTINE cp_sirius_feel_in_section
#endif

!     **************************************************************************************************
!     > \brief ...
!     > \param pwdft_env ...
!     > \param
!     > \par History
!     >      07.2018 start the Sirius library
!     > \author JHU
!     **************************************************************************************************
#if defined(__SIRIUS)
! **************************************************************************************************
!> \brief ...
!> \param pwdft_env ...
! **************************************************************************************************
         SUBROUTINE cp_sirius_energy_force(pwdft_env)
      TYPE(pwdft_environment_type), POINTER              :: pwdft_env

      CHARACTER(len=*), PARAMETER :: routineN = 'cp_sirius_energy_force', &
         routineP = moduleN//':'//routineN

      INTEGER                                            :: n1, n2
      REAL(KIND=C_DOUBLE)                                :: etotal
      REAL(KIND=C_DOUBLE), ALLOCATABLE, DIMENSION(:, :)  :: cforces
      REAL(KIND=C_DOUBLE), DIMENSION(3, 3)               :: cstress
      REAL(KIND=dp), DIMENSION(3, 3)                     :: stress
      REAL(KIND=dp), DIMENSION(:, :), POINTER            :: forces
      TYPE(C_PTR)                                        :: gs_handler = C_NULL_PTR
      TYPE(pwdft_energy_type), POINTER                   :: energy

            CPASSERT(ASSOCIATED(pwdft_env))
            CALL pwdft_env_get(pwdft_env=pwdft_env, gs_handler=gs_handler)
            CALL sirius_find_ground_state(gs_handler)
            CALL pwdft_env_get(pwdft_env=pwdft_env, energy=energy, forces=forces)
            etotal = 0.0_C_DOUBLE
            CALL sirius_get_energy(gs_handler, string('total'), etotal)
            energy%etotal = etotal
            n1 = SIZE(forces, 1)
            n2 = SIZE(forces, 2)
            ALLOCATE (cforces(n2, n1))
            cforces = 0.0_C_DOUBLE
            CALL sirius_get_forces(gs_handler, string('total'), cforces(1, 1))
! Sirius computes the forces but cp2k use the gradient everywhere
! so a minus sign is needed.
! note also that sirius and cp2k store the forces transpose to each other
! sirius : forces(coordinates, atoms)
! cp2k : forces(atoms, coordinates)
            forces = -TRANSPOSE(cforces(:, :))
            DEALLOCATE (cforces)
            cstress = 0.0_C_DOUBLE
            CALL sirius_get_stress_tensor(gs_handler, string('total'), cstress(1, 1))
            stress(1:3, 1:3) = cstress(1:3, 1:3)
            CALL pwdft_env_set(pwdft_env=pwdft_env, stress=stress)

         END SUBROUTINE cp_sirius_energy_force
#else
!     **************************************************************************************************
!     > \brief ...
!     > \param pwdft_env ...
!     **************************************************************************************************
! **************************************************************************************************
!> \brief ...
!> \param pwdft_env ...
! **************************************************************************************************
         SUBROUTINE cp_sirius_energy_force(pwdft_env)
      TYPE(pwdft_environment_type), POINTER              :: pwdft_env

            CPASSERT(ASSOCIATED(pwdft_env))
            CPABORT("Sirius library is missing")

         END SUBROUTINE cp_sirius_energy_force
#endif

      END MODULE sirius_interface
