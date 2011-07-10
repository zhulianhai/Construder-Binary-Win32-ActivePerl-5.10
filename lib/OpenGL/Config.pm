# This is the Perl OpenGL build configuration file.
# It contains the final OpenGL build arguements from
# the configuration process.  Access the values by
# use OpenGL::Config which defines the variable
#  containing the hash arguments from
# the WriteMakefile() call.
#
$OpenGL::Config = {
                    'NAME' => 'OpenGL',
                    'LIBS' => '',
                    'INC' => '',
                    'AUTHOR' => 'Bob \'grafman\' Free <grafman at graphcomp.com>',
                    'DEFINE' => '-DHAVE_VER -DHAVE_FREEGLUT -DHAVE_FREEGLUT32 -DHAVE_GL -DHAVE_GLU -DHAVE_GLU32 -DHAVE_GLUT -DHAVE_GLUT32 -DHAVE_OPENGL32',
                    'dynamic_lib' => {},
                    'OBJECT' => '$(BASEEXT)$(OBJ_EXT) gl_util$(OBJ_EXT) pogl_const$(OBJ_EXT) pogl_gl_top$(OBJ_EXT) pogl_glu$(OBJ_EXT) pogl_rpn$(OBJ_EXT) pogl_glut$(OBJ_EXT) pogl_gl_Accu_GetM$(OBJ_EXT) pogl_gl_GetP_Pass$(OBJ_EXT) pogl_gl_Mult_Prog$(OBJ_EXT) pogl_gl_Pixe_Ver2$(OBJ_EXT) pogl_gl_Prog_Clam$(OBJ_EXT) pogl_gl_Tex2_Draw$(OBJ_EXT) pogl_gl_Ver3_Tex1$(OBJ_EXT) pogl_gl_Vert_Multi$(OBJ_EXT)',
                    'clean' => {
                                 'FILES' => 'Config.pm utils/glversion.txt utils/glversion.exe utils/glversion.o'
                               },
                    'LDFROM' => '$(OBJECT) -lopengl32 -lglu32 -LFreeGLUT -lfreeglut',
                    'OPTIMIZE' => undef,
                    'PM' => {
                              'OpenGL.pm' => '$(INST_LIBDIR)/OpenGL.pm',
                              'Config.pm' => '$(INST_LIBDIR)/OpenGL/Config.pm',
                              'OpenGL.pod' => '$(INST_LIBDIR)/OpenGL.pod'
                            },
                    'EXE_FILES' => [],
                    'VERSION_FROM' => 'OpenGL.pm',
                    'XSPROTOARG' => '-noprototypes',
                    'PREREQ_PM' => {
                                     'Test::More' => 0
                                   }
                  };

1;
__END__
