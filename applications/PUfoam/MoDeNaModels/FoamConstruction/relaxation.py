"""
@file       relaxation.py
@namespace  FoamConstruction.relaxation
@ingroup    mod_foamConstruction
@brief      Relaxation of foam structure.
@author     Pavel Ferkl
@copyright  2014-2016, MoDeNa Project. GNU Public License.
@details
Uses Ken Brakke's Surface Evolver to anneal foam structure and remove very small
edges. The final morphology should be more representative of real foam
structure.
"""
import shutil
import subprocess as sp
def relax(fname):
    """Relax foam structure.
    Requires [se_api](https://github.com/kolarji2/SE_api) and
    [Evolver](http://facstaff.susqu.edu/brakke/evolver/evolver.html) to be
    installed."""
    call = sp.Popen(['se_api', '-i', fname + '.geo'])
    shutil.copy(fname + '.geo', fname + 'Unrelaxed.geo')
    call.wait()
    call = sp.Popen(['evolver', '-fse_cmd/main.cmd', fname.lower() + '.fe'])
    call.wait()
    shutil.move(fname.lower() + '_dmp.geo', fname + '.geo')
