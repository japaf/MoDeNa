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
import os
import shutil
import subprocess as sp
def relax(wdir, fname):
    """Relax foam structure.
    Requires [se_api](https://github.com/kolarji2/SE_api) and
    [Evolver](http://facstaff.susqu.edu/brakke/evolver/evolver.html) to be
    installed."""
    wfile = 'relax.cmd'
    call = sp.Popen(['se_api', '-i', fname + '.geo',
                     '-o', fname + '.fe'], cwd=wdir)
    call.wait()
    cmd = """
    read "../se_cmd/foamface.cmd"
    read "../se_cmd/distribution.cmd"
    read "../se_cmd/wetfoam2.cmd"
    read "../se_cmd/fe2geo.cmd"
    read "../se_cmd/relaxNE4.cmd"
    connected
    gogo
    detorus
    geo >>> "{}.geo"
    q\nq
    """.format(fname)
    with open(os.path.join(wdir, wfile), 'w') as wfl:
        wfl.write(cmd)
    call = sp.Popen(['evolver', '-f' + wfile, fname + '.fe'], cwd=wdir,
                    stdout=open(os.path.join(wdir, 'evolver.relax.log'), 'w'))
    call.wait()
    shutil.copy(os.path.join(wdir, fname + '.geo'),
                os.path.join(wdir, fname + 'Relaxed.geo'))


def create_struts(wdir, fname):
    """Create struts in dry foam."""
    wfile = 'struts.cmd'
    call = sp.Popen(['se_api', '-i', fname + '.geo',
                     '-o', fname + '.fe'], cwd=wdir)
    call.wait()
    cmd = """
    read "../se_cmd/wetfoam2.cmd"
    spread := 0.2
    wetfoam >>> "{}Struts.fe"
    q\nq
    """.format(fname)
    with open(os.path.join(wdir, wfile), 'w') as wfl:
        wfl.write(cmd)
    call = sp.Popen(['evolver', '-f' + wfile, fname + '.fe'], cwd=wdir,
                    stdout=open(os.path.join(wdir, 'evolver.wetfoam.log'), 'w'))
    call.wait()
    wfile = 'struts2.cmd'
    cmd = """
    read "../se_cmd/fe2geo.cmd"
    connected
    detorus
    geo >>> "{}.geo"
    q\nq
    """.format(fname)
    with open(os.path.join(wdir, wfile), 'w') as wfl:
        wfl.write(cmd)
    call = sp.Popen(['evolver', '-f' + wfile, fname + 'Struts.fe'], cwd=wdir,
                    stdout=open(os.path.join(wdir, 'evolver.struts.log'), 'w'))
    call.wait()
    # wfile = "remove_surfaces.geo"
    # outfile = fname + '.geo'
    # with open(wfile, 'w') as wfl:
    #     wfl.write('SetFactory("OpenCASCADE");\n\n')
    #     wfl.write('Include "{0}";\n\n'.format(outfile))
    #     sdat = read_geo(outfile)  # string data
    #     sdat.pop('physical_surface')
    #     edat = extract_data(sdat)  # extracted data
    #     surfs = edat['surface'].keys()
    #     ssurfs = ','.join('{}'.format(j) for i, j in enumerate(surfs))
    #     sdat = collect_strings(edat)
    #     save_geo(outfile, sdat)
    #     wfl.write('Recursive Delete{{Surface{{{0}}};}}\n'.format(ssurfs))
    # call = sp.Popen(['gmsh', wfile, '-0'])
    # call.wait()
    # shutil.move(wfile + '_unrolled', outfile)
    shutil.copy(os.path.join(wdir, fname + '.geo'),
                os.path.join(wdir, fname + 'Struts.geo'))
