function Fname = FullName (filename)
% Find the full file name for an existing file. The input file name refers
% to a file on the Matlab path (including in the current directory) or has
% a relative or absolute pathname. This routine is meant to be used to
% return the full file name for a file that has been opened. The full name
% can then be printed, for instance to log the operations on that file.
%
% The assumption will be that the file has been opened with fopen. Note
% that fopen will open files which are specified with a relative or
% absolute path. It will also open files that are on the Matlab path.

% The returned file name is the input name if the file is not found.

% $Id: FullName.m,v 1.4 2009/07/11 11:33:20 pkabal Exp $

% Matlab's behaviour for accessing files can lead to problems in
% discovering the location of a file. Matlab supports partial pathnames,
% i.e. paths relative to "matlabpath", for some commands (see
% "help partialpath"). The "which" and "fopen" commands are such commands.
% However, they do not behave entirely the same way.

% Some examples of disagreements between the Matlab functions are shown
% below (tested with Matlab 2008a).
%   (a) 'abc.m' exists, 'abc' (no extension) does not exist.
%         fopen('abc') fails
%         ls('abc') fails
%         exist('abc') succeeds
%         which('abc') succeeds with 'abc.m'
%   (b) '../../d1/d2/abc.m' exists
%         fopen('../../d1/d2/abc.m') succeeds
%         ls('../../d1/d2/abc.m') succeeds
%         exist('../../d1/d2/abc.m') succeeds
%         which('../../d1/d2/abc.m') fails
%   (c) '<dir>' is part of the Matlab path, '<dir>/abc.m' exists.
%         fopen('abc.m') succeeds
%         ls('abc.m') fails
%         exist('abc.m') succeeds
%         which('abc.m') succeeds
%   (d) '<dir>' is part of the Matlab path, '<dir>/private/abc.m' exists.
%         fopen('private/abc.m') succeeds
%         ls('private/abc.m') fails
%         exist('private/abc.m') succeeds
%         which('private/abc.m') succeeds

% Try ls first
Fname = ls_File (filename);

% If necessary try "which"
if (isempty (Fname))
  Fname = Which_File (filename);
end

if (isempty (Fname))
  Fname = filename;
end

return

% ----- -----
function Fname = ls_File (File)

% This function tests if a file exists. This routine is meant to anticipate
% that an fopen can open the given file for reading.
Fname = [];

lsFile = ls (File);
if (~ isempty (lsFile))

  [dirn name ext] = fileparts (File);
  bname = [name ext];    

  if (~ isempty (dirn))
    PWDsave = pwd;
    cd (dirn);     % Should work, since "ls" found the file
    Fname = fullfile (pwd, bname);
    cd (PWDsave);
  else
    Fname = fullfile (pwd, bname);
  end
end

return

% ----- -----
function Fname = Which_File (File)

[dirn name ext versn] = fileparts (File);
bname = [name ext versn];

Fname = [];

Which_File = which (File);
if (~ isempty (Which_File))

  % Check that the file found by "which" has the same name as desired
  % ("which" appends extensions such as ".m" if no extension is given)
  % - check that the name parts match and that the file exists
  [dirn name ext versn] = fileparts (Which_File);
  Wbname = [name ext versn];
  if (strcmp (Wbname, bname) && ~ isempty(ls (Which_File)))
    Fname = Which_File;
  end

end

return
