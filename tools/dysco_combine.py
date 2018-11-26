#!/bin/python
import sys


import casacore.tables as pt


def addcolumn(t, newcolname, likecolname):
    """
    Adds a column to a table if it does not exist.
    The new column will be like @likecolname@.
    """

    if newcolname in t.colnames():
        return  # Column already exists

    coldesc = t.getcoldesc(likecolname)
    coldesc['name'] = newcolname
    coldesc.pop('comment', None)
    t.addcols(coldesc)

def combine_ms(ms_final, ms_corrected):
    read_t = pt.table(ms_corrected)
    write_t = pt.table(ms_final, readonly=False)

    addcolumn(write_t, "CORRECTED_DATA", "DATA")
    for read_t_timechunk, write_t_timechunk in zip(read_t.iter("TIME"), write_t.iter("TIME")):
       write_t_timechunk.putcol("CORRECTED_DATA", read_t_timechunk.getcol("DATA"))

if __name__ == '__main__':
    combine_ms(sys.argv[1], sys.argv[2])

